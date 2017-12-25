# -*- coding: utf-8 -*-

Plugin.create(:stream_command_update_icon) do

  @enable_update_icon = true

  # @param [Plugin::Twitter::World] twitter Twitter World
  # @param [String] icon Base64でエンコードされた新しいプロフィール画像
  defspell(:update_profile_icon, :twitter) do |twitter, icon:|
    (twitter/'account/update_profile_image').json(image: icon)
  end

  # update_icon : 3 requests / 15 min
  stream_command(:update_icon,
                 rate_limit: 3,
                 rate_limit_reset: 15) do |msg, *args|
    # 宛先ユーザのWorldを取得
    service = Plugin.filtering(:worlds, [])[0].find(&msg.method(:to_me?))
    unless @enable_update_icon
      compose(service, msg, body: "@#{msg.user.idname} 現在、update_iconを一時中止しています... #{Time.now}")
      next
    end

    # 変更先アイコン名を取得する randomなら適当に見繕う
    icon_name = args[0].gsub(/(\s|　|\.|\/|~)+/, '')
    icon_name = get_icon_list.sample if icon_name == 'random'
    filename = File.join(File.dirname(__FILE__), 'icons', "#{icon_name}.png")

    if File.exist?(filename) && !service.nil?
      File.open(filename) do |io|
        update_profile_icon(service, icon: Base64.encode64(io.read)).next do
          compose(service, msg, body: ".@#{msg.user.idname}さんの要望でアイコンを\"#{icon_name}\"に変更します (#{Time.now})")
        end.trap do |e|
          warn e
          compose(service, msg, body: "@#{msg.user.idname} エラーが発生したため、変更できませんでした (#{Time.now})")  
        end
      end
    else
      compose(service, msg, body: "@#{msg.user.idname} 申し訳ありませんが、その色のアイコンはないのです... (#{Time.now})")
    end
  end

  stream_command(:enable_update_icon,
                 private: true) do |msg, *args|
    @enable_update_icon = args[0] == "true"
    service = Plugin.filtering(:worlds, [])[0].find(&msg.method(:to_me?))
    compose(service, msg, body: "@#{msg.user.idname} update_iconの状態を変更 => #{args[0]}")
  end

  # アイコン画像パスの一覧を取得する。
  #
  # @return [String]
  def get_icon_list
    Dir.glob(File.join(File.dirname(__FILE__), 'icons', '*.png')).map { |f| File.basename(f, '.png') }
  end

end
