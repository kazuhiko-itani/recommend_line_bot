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

post '/callback' do
  body = request.body.read
  google_client = Google_drive.new

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
      when Line::Bot::Event::Message
        case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: event['source']['userId']
            }
            client.reply_message(event['replyToken'], message)
        end

      when Line::Bot::Event::Follow
        google_client.insert_user_id(event['source']['userId'])
        message = {
          type: 'text',
          text: event['source']['userId']
        }
        client.reply_message(event['replyToken'], message)

      when Line::Bot::Event::UnFollow
        google_client.delete_user_id(event['source']['userId'])
    end
  }

  'OK'
end

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

  client.push_message('U84fb7fffcba694b77855a55a93abc0ab', message)
  client.push_message('U84fb7fffcba694b77855a55a93abc0ab', image)
  'OK'
end