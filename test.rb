require 'nokogiri'

# xmlファイルから取得する曲情報のkey
key_names = [
  'Name',
  'Artist',
  'Album Artist',
  'Composer',
  'Album',
  'Genre',
  'Total Time',
  'Year',
  'Date Modified',
  'Date Added',
  'Play Count',
  'Play Date',
  'Play Date UTC',
  'Rating',
  'Album Rating'
]

# コマンドライン引数で指定されたxmlファイルを読み込み
file = ARGV[0]
xml  = Nokogiri::XML(open(file).read)

# 曲情報を取得して整形
songs = xml.xpath('plist/dict/dict/dict')
song_info_list = []
songs.each do |song|
  song_info = {}

  keys = song.xpath('key')
  keys.each do |key|
    if key_names.include?(key.content)
      key_name = key.content
      song_info[key_name] = key.next.content
    end
  end

  song_info_list.push(song_info)
end

# elasticsearchに登録ためのjsonファイルに書き出し
File.open('itunes.json', 'w') do |file|
  song_info_list.each do |song_info|
    file.puts('{')
    song_info.each { |name, value| file.puts "\"#{name}\": \"#{value}\"," }
    file.puts('},')
  end
end
