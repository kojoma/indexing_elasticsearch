require 'mechanize'
require 'Date'

# Googleのログイン情報
login_url = 'https://www.google.com/accounts/Login?hl=ja&continue=http://www.google.co.jp/'
login_email = ARGV[0]
login_pass = ARGV[1]

# mechanizeのエージェント
agent = Mechanize.new
agent.get(login_url)

# Googleにログイン
form = agent.page.forms.first
form.Email  = login_email
form.Passwd = login_pass
agent.submit(form)

# Moves Exportからデータを取得してjsonファイルに出力
moves_url  = 'http://www.moves-export.com/jsonstoryline?startdate='
start_date = Date.new(2013, 3, 4)
end_date   = Date.today
File.open('moves.json', 'w') do |file|
  while start_date < end_date do
    start_date_str = start_date.strftime("%Y%m%d")
    agent.get(moves_url + start_date_str)
    file.puts(agent.page.body)
    start_date = start_date + 1
  end
end
