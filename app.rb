require 'sinatra'
require 'lib/yasi'

before do
  Yasi.connect :server => "localhost", :port => 27017, :db => "yasi"
end

get '/' do
  @yasis = Yasi.find :all
  erb :index
end

get '/new' do
  erb :new
end

# ok, it should be a delete method
get '/delete/:id' do
  Yasi.delete(params[:id])
  redirect "/"
end

post "/create" do
  Yasi.save(params["yasi"])
  redirect "/"
end