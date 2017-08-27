require 'bundler/setup'
require __FILE__.sub('config.ru','web.rb')

run Sinatra::Application

