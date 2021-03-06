# opkg install ruby-readline ruby-openssl ruby-irb ruby-gems ruby ruby-json
# opkg install ruby-enc-extra
require 'sinatra'
# require 'sinatra/reloader'
# require 'sequel'
# DB = Sequel.sqlite
# DB.create_table :crons do
#   primary_key :id
#   Integer  :pipe_id
#   String   :pipe_name
#   String   :name
#   Datetime :switch_on_at
#   Datetime :switch_off_at
#   String   :repeat
# end
# DB[:crons].insert(pipe_id: id, pipe_name: "Default", switch_on_at: Time.now, switch_off_at: Time.now+3600*2)
# DB[:crons].insert(pipe_id: id, pipe_name: "Default", switch_on_at: Time.now+3600*2, switch_off_at: Time.now+3600*3, repeat: "every week Sunday")



enable :sessions

get '/' do
  redirect '/pipes'
end



get '/pipes' do
  str = "<table><tr><th>ID</th><th>Name</th><th>Info</th><th></th></tr>"
  Pipe.each do |pipe|
    str << "<tr><td>#{pipe.id}</td><td>#{pipe.name}</td><td>#{pipe.inspect}</td><td><a href='/pipes/#{pipe.id}'>Show</a><a href='/pipes/#{pipe.id}/edit'>Edit</a></td></tr>"
  end
  str << "</table>"
  str << "<br> <a href='/pipes/new'>Add new</a>"
end

get '/pipes/new' do
  erb :pipe_form, locals: {pipe: {}}
end

get '/pipes/:id' do
  pipe = Pipe.find(params[:id])
  erb :pipe, locals: {pipe: pipe, crons: {}}#DB[:crons]}
end

get '/pipes/:id/turnon/:time' do
  pipe = Pipe.find(params[:id])
  erb :pipe, locals: {pipe: pipe}
end


get '/pipes/:id/edit' do
  pipe = Pipe.find(params[:id])
  erb :pipe_form, locals: {pipe: pipe}
end

post '/pipes' do
  keys = %i(name group pin)
  pipe=Pipe.new(keys.each_with_object({}){|k,h| h[k]=params[k] })
  pipe.id = params[:id] if params[:id]
  pipe.save
  redirect '/pipes'
end