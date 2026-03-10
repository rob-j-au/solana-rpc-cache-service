require 'sinatra'

set :bind, '0.0.0.0'
set :port, 4000
set :views, File.join(settings.root, 'views')

get '/' do
  erb :index
end
