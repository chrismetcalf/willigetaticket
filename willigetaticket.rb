require "sinatra"
require 'sinatra/json'
require 'soda/client'
require 'time'
require 'erb'
require 'sass'

class WillIGetATicket < Sinatra::Base
  set :public_folder, Proc.new { File.join(root, "static") }

  before do
    @soda = SODA::Client.new(:app_token => ENV["SOCRATA_APP_TOKEN"], :domain => ENV["SOCRATA_DOMAIN"])
  end

  get '/' do
    erb :index
  end

  get '/where/:lat/:lon' do
    lat = params[:lat]
    lon = params[:lon]
    range = ENV["RANGE"].to_i
    bounds = ENV["BOUNDS"].to_i
    now = Time.now

    # Pull the tickets within the given radius
    @tickets = @soda.get("n2hc-t292", {"$where" => "within_circle(location, #{lat}, #{lon}, #{range})", "$order" => "datetime"})

    # Filter out only results from around the same time
    @tickets.reject! { |ticket|
      ((now - Time.parse(ticket.datetime.split(/T/)[1])) / 60).abs > bounds
    }

    results = {
      :location => [lat, lon],
      :range => range,
      :bounds => bounds,
      :count => @tickets.count,
      :tickets => @tickets
    }

    json results
  end

  get "/css/classy.css" do
    sass :classy
  end

end
