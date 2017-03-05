# -*- coding: utf-8 -*-

Plugin.create(:stream_command_update_icon) do

  @enable_update_icon = true

  # update_icon : 3 requests / 15 min
  stream_command(:update_icon,
                 rate_limit: 3,
                 rate_limit_reset: 15) do |msg, *args|
    service = Service.find { |s| msg.receive_to? s.user_obj }
    unless @enable_update_icon
      service.twitter.post(message: "@#{msg.user.idname} 現在、update_nameを一時中止しています... #{Time.now}")
      next
    end

    # 変更先アイコン名を取得する randomなら適当に見繕う
    icon_name = args[0].gsub(/(\s|　|\.|\/|~)+/, '')
    icon_name = get_icon_list.sample if icon_name == 'random'
    filename = File.join(File.dirname(__FILE__), 'icons', "#{icon_name}.png")

    if File.exist?(filename) && !service.nil?
      File.open(filename) do |io|
        service.twitter.update_profile_image(io).next do
          service.twitter.post(message: ".@#{msg.user.idname}さんの要望でアイコンを\"#{icon_name}\"に変更します (#{Time.now})", 
                               replyto: msg.id)
        end
      end
    else
      service.twitter.post(message: "@#{msg.user.idname} 申し訳ありませんが、その色のアイコンはないのです... (#{Time.now})",
                           replyto: msg.id)
    end
  end

  stream_command(:enable_update_icon,
                 private: true) do |msg, *args|
    @enable_update_icon = args[0] == "true"
    msg.post(message: "@#{msg.user.idname} update_iconの状態を変更 => #{args[0]}")
  end

  # アイコン画像パスの一覧を取得する。
  #
  # @return [String]
  def get_icon_list
    Dir.glob(File.join(File.dirname(__FILE__), 'icons', '*.png')).map { |f| File.basename(f, '.png') }
  end

end

module MikuTwitter::APIShortcuts

  def update_profile_image(io)
    (self/'account/update_profile_image').json image: Base64.encode64(io.read)
  end

end
