require 'sinatra'
require 'lib/sat'

before do
  Sat.connect
end

get '/' do
  erb :index
end

get '/all' do
  @cnfs = Sat.find :all, params[:cnf]
  erb :all
end

get '/show/:id' do
  @cnf = Sat.find :one, { "_id" => params[:id] }
  erb :show
end

get '/delete/:id' do
  Sat.delete(params[:id])
  redirect "/"
end

post "/create" do
  id = Sat.save(params["cnf"])
  redirect "/show/#{id}"
end
