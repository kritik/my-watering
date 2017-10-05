# require 'bundler/setup'
require 'rack'
require 'yaml'
require "erb"

SDB= "database.yml"

require __FILE__.sub('config.ru','pipe.rb')


class Web
  def self.req
    @req
  end

  def self.folder
    @folder||=__FILE__.sub('config.ru','')
  end

  def self.pipe_index
    str = "<table><tr><th>ID</th><th>Name</th><th>Info</th><th></th></tr>"
    Pipe.each do |pipe|
      str << "<tr><td>#{pipe.id}</td><td>#{pipe.name}</td><td>#{pipe.inspect}</td><td><a href='/pipes/#{pipe.id}'>Show</a><a href='/pipes/#{pipe.id}/edit'>Edit</a></td></tr>"
    end
    str << "</table>"
    str << "<br> <a href='/pipes/new'>Add new</a>"
  end

  def self.pipe_new pipe: {}
    b = binding
    b.local_variable_set(:pipe, pipe)
    ERB.new(File.read(folder+"views/pipe_form.erb")).result(b)
  end

  def self.redirect url
    state = req.get? ? 302 : 303
    [state, {'Location' => url, 'Content-Type' => 'text/html'}, ['Redirect']]
  end

  def self.call(env)
    @req = Rack::Request.new(env)
    resp = ""

    p req.path_info
    p req.post?
    p req.params
    if req.path_info.start_with?("/pipes")
      if req.path_info.eql?("/pipes") && req.get? #index
        resp=pipe_index
      elsif req.path_info.eql?('/pipes/new') #new
        resp=pipe_new
      elsif req.path_info.start_with?('/pipes/') && req.path_info.end_with?('/edit') # edit
        id = req.path_info.split("/")[-2]
        pipe = Pipe.find(id)
        resp=pipe_new(pipe: pipe)
      elsif req.path_info.eql?('/pipes') && req.post? #create/update
        keys = %w(name group pin)
        pipe=Pipe.new(keys.each_with_object({}){|k,h| h[k]=req.params[k] })
        pipe.id = req.params["id"] if req.params["id"]
        pipe.save
        return redirect('/pipes')
      end
    else
      return redirect("/pipes")
    end
    [ 200, {"Content-Type" => "text/html"}, [resp] ]
  end
end
use Rack::Reloader
run Web
# run Sinatra::Application

