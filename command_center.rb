require 'sinatra/base'
require 'yaml'

class CommandCenter < Sinatra::Application
  configure do
    Projectify.configure do |config|
      addresses = YAML.load_file("projector_addresses.yml") || begin
        puts "WARNING: No projector addresses were found in `projector_addresses.yml`.  Add all projector IP or local addresses in this file."
        addresses = []
      end
      config.projector_addresses = addresses
    end
  end

  get '/' do
    @broadcaster = Projectify::Broadcaster.new
    if @broadcaster.any?(:power_transitioning?)
      @meta_refresh_interval = 2 #seconds
    end
    haml :simple
  end

  post '/power_on' do
    Projectify::Broadcaster.new.call(:power_on)
    redirect '/'
  end

  post '/power_off' do
    Projectify::Broadcaster.new.call(:power_off)
    redirect '/'
  end
end