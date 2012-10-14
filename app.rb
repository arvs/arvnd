require 'bundler/setup'
require 'sinatra'
require 'mustache/sinatra'

class App < Sinatra::Base
  register Mustache::Sinatra
  require './views/layout'

  set :mustache, {
    :views     => './views',
    :templates => './templates'
  }

  get '/' do
    @title = "Mustache + Sinatra = Wonder"
    mustache :index
  end

end