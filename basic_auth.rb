def protect!
  unless authorized?
    response['WWW-Authenticate'] = %(Basic realm = "Restricted Area")
    throw(:halt, "Not authorized\n")
  end
end

def authorized?
  auth ||= Rack::Auth::Basic::Request.new(request.env)
  username = ENV['BASIC_AUTH_USERNAME']
  password = ENV["LINE_CHANNEL_TOKEN"]
  auth.provided? && auth.basic? && 
            auth.credentials && auth.credentials == [username, password]
end