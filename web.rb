require 'rack'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sequel'
require 'pry'

DB = Sequel.sqlite
DB.create_table :pipes do
  primary_key :id
  String :name
  String :group
  Integer :pin, unique: true
end
DB.create_table :crons do
  primary_key :id
  Integer  :pipe_id
  String   :pipe_name
  String   :name
  Datetime :switch_on_at
  Datetime :switch_off_at
  String   :repeat
  Boolean :is_active, default: false
end

id=DB[:pipes].insert(name: "Default", group: "Back of home", pin: 1)
DB[:crons].insert(pipe_id: id, pipe_name: "Default", switch_on_at: Time.now, switch_off_at: Time.now+3600*2)
DB[:crons].insert(pipe_id: id, pipe_name: "Default", switch_on_at: Time.now+3600*2, switch_off_at: Time.now+3600*3, repeat: "every week Sunday")
require './pipe.rb'
p Pipe.first.active?


enable :sessions

get '/' do
  redirect '/pipes'
end



get '/pipes' do
  str = "<table><tr><th>ID</th><th>Name</th><th>Info</th><th></th></tr>"
  DB[:pipes].each do |pipe|
    str << "<tr><td>#{pipe[:id]}</td><td>#{pipe[:name]}</td><td>#{pipe.inspect}</td><td><a href='/pipes/#{pipe[:id]}'>Show</a><a href='/pipes/#{pipe[:id]}/edit'>Edit</a></td></tr>"
  end
  str << "</table>"
  str << "<br> <a href='/pipes/new'>Add new</a>"
end

get '/pipes/new' do
  erb :pipe_form, locals: {pipe: {}}
end

get '/pipes/:id' do
  pipe = DB[:pipes].find(params[:id]).first
  erb :pipe, locals: {pipe: pipe, crons: DB[:crons]}
end

get '/pipes/:id/turnon/:time' do
  pipe = DB[:pipes].find(params[:id]).first
  erb :pipe, locals: {pipe: pipe}
end


get '/pipes/:id/edit' do
  pipe = DB[:pipes].find(params[:id]).first
  erb :pipe_form, locals: {pipe: pipe}
end

post '/pipes' do
  pipes = DB[:pipes]
  keys = %i(name group pin is_active)
  id = pipes.insert(keys.each_with_object({}){|k,h| h[k]=params[k] })
  redirect '/pipes'
end