require 'nokogiri'

file = ARGV[0]
xml  = Nokogiri::XML(open(file).read)

songs = xml.xpath('plist/dict/dict/dict')

song_info_list = []
for song in songs
    song_info = {}
    key = ""

keys = song.xpath('key')
keys.each do |key|
    p key.content
end
    song.each do |element|
      if element.tag == "key"
            key = element.text
        else
            song_info[key] = element.text
            song_info_list.push(song_info)
        end
    end

if 0
    for element in song
        if element.tag == "key"
            key = element.text
        else
            song_info[key] = element.text
            song_info_list.push(song_info)
        end
    end
end
end

p song_info_list[0]
