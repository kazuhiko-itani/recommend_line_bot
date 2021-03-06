require './amazon_ranking.rb'
require './google_drive.rb'
require './basic_auth.rb'
require './helpers.rb'

require 'sinatra'
require 'line/bot'
require 'uri'

get '/' do
	'hello!'
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

# フレンド登録、ブロック、ブロック解除時に参照されるURL
post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    google_client = Google_drive.new
    user_id = event['source']['userId']
    case event
      # メッセージが送信されたときに実行されるイベント
      when Line::Bot::Event::Message
        message = {
          type: 'text',
          text: '返信には対応していません。ごめんね。'
        }
        client.reply_message(event['replyToken'], message)
      # 友達登録、ブロック解除されたときに実行されるイベント
      when Line::Bot::Event::Follow
        google_client.insert_user_id(user_id)
      # ブロックされたときに実行されるイベント
      when Line::Bot::Event::Unfollow
        google_client.delete_user_id(user_id)
    end
  }

  'OK'
end

# このURLを叩くことでおすすめ本メッセージが登録者全員に送信される
get '/send' do
  protect!

  ranking_list = scraping_amazon_ranking
  book_title, book_url, book_image = return_title_url_image(ranking_list)
  anounce_message = '【今日のおすすめの1冊】'

  message = {
    type: 'text',
    text: "#{anounce_message}\n#{book_title}\n#{book_url}"
  }
  image = {
    type: 'image',
    originalContentUrl: book_image,
    previewImageUrl: book_image
  }

  google_client = Google_drive.new
  rows_count = google_client.return_rows
  for count in 1..rows_count do
    client.push_message(google_client.get_user_id(count), message)
    client.push_message(google_client.get_user_id(count), image)
  end
  'OK'
end