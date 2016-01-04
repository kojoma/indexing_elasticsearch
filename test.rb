require 'nokogiri'

file = ARGV[0]
xml  = Nokogiri::XML(open(file).read)

songs = xml.xpath('plist/dict/dict/dict')
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

song_info_list = []
for song in songs
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
