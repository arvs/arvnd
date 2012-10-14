require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'zurb-foundation'
require 'mustache/sinatra'

class App < Sinatra::Base
  configure :production, :development do
    enable :logging
  end
  configure do
    Compass.configuration do |config|
      config.project_path = File.dirname __FILE__
      config.sass_dir = File.join "views", "scss"
      config.images_dir = File.join "public", "images"
      config.http_path = "/"
      config.http_images_path = "/images"
      config.http_stylesheets_path = "/stylesheets"
    end
    set :scss, Compass.sass_engine_options
  end


  register Mustache::Sinatra
  require './views/layout'

  set :mustache, {
      :views     => './views',
      :templates => './templates'
  }

  get '/' do
    mustache :index
  end
  
  get "/stylesheets/*.css" do |path|
    content_type "text/css", charset: "utf-8"
    scss :"scss/#{path}"
  end
end