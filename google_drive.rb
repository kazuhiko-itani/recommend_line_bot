require 'google_drive'
require 'pp'
require 'oauth2'

def client_google_drive
  client_id = '213419125002-iatgcvtrvbaq81olhftvq4rh81ks56c3.apps.googleusercontent.com'
  client_secret = 'b1hdJcc40yY7huXP6qW_090M'
  refresh_token = '1/49bNCoIDpPA_ubrWDoIagUDVFtJuptRNtB14QB9gAjA'
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

  #p ws.num_rows
  #p ws.num_cols
  #p ws[1, 1]

  #ws[1, 1] = 'test' #if ws[1, 1] == nil
  #p ws[1, 1]

  #ws.delete_rows(1, 2)
  #ws.save
end

def insert_user_id(user_id)
  data_rows = @ws.num_rows
  @ws[(data_rows + 1), 1] = user_id
  @ws.save
end