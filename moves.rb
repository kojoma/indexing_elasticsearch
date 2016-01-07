require 'mechanize'
require 'Date'
require 'elasticsearch'
require 'json'

# Googleの情報
GOOGLE_URL   = 'https://www.google.com/accounts/Login?hl=ja&continue=http://www.google.co.jp/'
GOOGLE_EMAIL = ARGV[0]
GOOGLE_PASS  = ARGV[1]
# Moves Exportの情報
MOVES_URL = 'http://www.moves-export.com/jsonstoryline?startdate='
# elasticsearch(ES)の情報
ES_HOST = 'https://search-moves-analyze-3y6ogtaepp3w3ynlwa52gayuye.ap-northeast-1.es.amazonaws.com/'

# mechanizeのエージェント
agent = Mechanize.new
agent.get(GOOGLE_URL)

# Googleにログイン
form = agent.page.forms.first
form.Email  = GOOGLE_EMAIL
form.Passwd = GOOGLE_PASS
agent.submit(form)

# elasticsearchのクライアント
client = Elasticsearch::Client.new(host: ES_HOST,
                                   transport_options: { headers: { content_type: 'application/json' } }
                                  )

# Moves Exportからデータを取得してelasticsearchに登録
start_date = Date.new(2013, 3, 4)
end_date = Date.new(2013, 3, 10)
#end_date   = Date.today
while start_date < end_date do
  start_date_str = start_date.strftime("%Y%m%d")
  agent.get(MOVES_URL + start_date_str)

  json    = JSON.parse(agent.page.body)
  summary_list = json[0]['summary']
  summary_list.each do |summary|
=begin
    client.create index: 'moves', type: 'summary', body: {
      date: start_date.strftime("%Y-%m-%d"),
      distance: summary['distance'],
      duration: summary['duration'],
      calories: summary['calories'],
      steps: summary['steps'],
      group: summary['group'],
      activity: summary['activity']
    }
    p 'summary: ' + start_date.strftime("%Y-%m-%d")
=end
  end

  segments = json[0]['segments']
  segments.each do |segment|
    activities = segment['activities']

    if activities.nil?
      start_time = DateTime.parse(segment['startTime'])
      end_time   = DateTime.parse(segment['endTime'])
      start_time_str = start_time.strftime("%Y-%m-%d %H:%M:%S")
      end_time_str   = end_time.strftime("%Y-%m-%d %H:%M:%S")
      client.create index: 'moves', type: 'geo', body: {
        start_time: start_time_str,
        end_time:   end_time_str,
        distance:   0,
        duration:   0,
        calories:   0,
        steps:      0,
        group:      '',
        activity:   '',
        location:   {
          lon:      segment['place']['location']['lon'],
          lat:      segment['place']['location']['lat']
        }
      }
    else
      activities.each do |activity|
        track_points = activity['trackPoints']
        start_time = DateTime.parse(activity['startTime'])
        end_time   = DateTime.parse(activity['endTime'])
        start_time_str = start_time.strftime("%Y-%m-%d %H:%M:%S")
        end_time_str   = end_time.strftime("%Y-%m-%d %H:%M:%S")

        if track_points.nil?
          client.create index: 'moves', type: 'geo', body: {
            start_time: start_time_str,
            end_time:   end_time_str,
            distance:   activity['distance'],
            duration:   activity['duration'],
            calories:   activity['calories'],
            steps:      activity['steps'],
            group:      activity['group'],
            activity:   activity['activity'],
            location:   {
              lon:      segment['place']['location']['lon'],
              lat:      segment['place']['location']['lat']
            }
          }
        else
          track_points.each do |track_point|
            client.create index: 'moves', type: 'geo', body: {
              start_time: start_time_str,
              end_time:   end_time_str,
              distance:   activity['distance'],
              duration:   activity['duration'],
              calories:   activity['calories'],
              steps:      activity['steps'],
              group:      activity['group'],
              activity:   activity['activity'],
              location:   {
                lon:      track_point['lon'],
                lat:      track_point['lat']
              }
            }
          end
        end
      end
    end
    p 'geo: ' + start_date.strftime("%Y-%m-%d")
  end

  start_date = start_date + 1
end
