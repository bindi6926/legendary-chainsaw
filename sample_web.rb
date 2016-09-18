# Web画面からデータを入力して、データベース（SQLite）に登録します。
# サンプルプログラムとして作成したため、登録処理のみの状態です。
# Ctrl+Cで処理を中断できます。
#
# 起動方法
# 1. このプログラム（sample_web.rb）を起動します。
# 2. Webブラウザを起動して、「http://localhost:9999/index.html」と入力します。
#----------------------------------------------------------------

# -*- coding: utf-8 -*-
require "rubygems"
require "webrick"
require "erb"
require "dbi"

# 9999は使用してなさそうな数字を選択
config = {
	:Port => 9999,
	:DocumentRoot => '.',
	}

# サーバーの設定	
WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
server = WEBrick::HTTPServer.new( config )
server.config[:MimeTypes]["erb"] = "text/html"

# データの登録
server.mount_proc("/entry") {|req, res|
	# データベースの接続
	dbh = DBI.connect( 'DBI:SQLite3:sample.db' )
	
	# テーブル（sampleid）へデータを追加
	dbh.do("insert into sampleid values('#{req.query['id']}','#{req.query['name']}');")
	
	# データベースの切断
	dbh.disconnect
	
	# データの登録後の処理
	temp = ERB.new( File.read('sample_entry_ok.erb') )
	res.body << temp.result( binding )
}

# Ctrl + Cで処理を中断して終了
trap(:INT) do
	server.shutdown
end

server.start