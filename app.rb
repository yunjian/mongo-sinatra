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

get '/delete/:id' do
  Sat.delete(params[:id])
  redirect "/"
end

post "/create" do
  Sat.save(params["cnf"])
  redirect "/all"
end
