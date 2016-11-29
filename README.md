# stream_command_update_icon

## なにこれ
stream_commandのプラグインです。  
アイコンを変更するコマンドと、実行許可を制御するコマンドを使えるようにします。

## 必要なもの
* stream_commandプラグイン
* png形式のアイコン用画像（たくさんあると楽しいよ）

## コマンド
#### update_icon filename|random
アイコンを変更します。名前が指名されている場合はそのアイコンファイルを、randomであれば適当にチョイスします。

#### enable_update_icon true|false
アイコン変更の実行許可を制御します。拒否中は誰も変更できなくなります。
