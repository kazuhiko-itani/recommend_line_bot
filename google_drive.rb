require 'google_drive'
require 'oauth2'

class Google_drive

  # OAuth2.0認可を行い、スプレッドシート情報を取得する
  def initialize
    client_id = ENV['GOOGLE_CLIENT_ID']
    client_secret = ENV['GOOGLE_CLIENT_SECRET']
    refresh_token = ENV['GOOGLE_REFRESH_TOKEN']
    client = OAuth2::Client.new(
      client_id,
      client_secret,
      site: 'https://accounts.google.com',
      token_url: '/o/oauth2/token',
      authorize_url: '/o/oauth2/auth'
      )
    auth_token = OAuth2::AccessToken.from_hash(client, { refresh_token: refresh_token, expires_at: 3600 })
    auth_token = auth_token.refresh!
    session = GoogleDrive.login_with_oauth(auth_token.token)
    @ws = session.spreadsheet_by_key('1ZuBmavwQeo2KUxQ-2BURJP3MJF4ewzQXSF2I0TQcmVE').worksheets[0]
  end

  # スプレッドシートの現在の行数をreturnする
  def return_rows
    @ws.num_rows
  end

  # スプレッドシートからユーザーIDを取得し、returnする
  def get_user_id(row_num)
    @ws[row_num, 1]
  end

  # スプレッドシートにユーザーIDを登録する
  def insert_user_id(user_id)
    data_rows = @ws.num_rows
    @ws[(data_rows + 1), 1] = user_id
    @ws.save
  end

  # フォロー解除（ブロック）された時にスプレッドシートからuserIdを消去する
  # DBのほうが効率いいはずだけど、これは練習の一環・・・
  def delete_user_id(user_id)
    for count in 1..@ws.num_rows do
      id = @ws[count, 1]
      if id == user_id
        @ws.delete_rows(count, 1)
        @ws.save
        break
      end
    end
  end

end