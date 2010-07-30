require 'sinatra'
require 'lib/yasi'

before do
  Yasi.connect
end

get '/' do
  @yasis = Yasi.find :all, params[:yasi]
  erb :index
end

get '/new' do
  erb :new
end

get '/show/:id' do
  @yasi = Yasi.find :one, { "_id" => params[:id] }
  erb :show
end

# should be a delete method
get '/delete/:id' do
  Yasi.delete(params[:id])
  redirect "/"
end

post "/create" do
  Yasi.save(params["yasi"])
  redirect "/"
end