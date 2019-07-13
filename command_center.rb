require 'sinatra/base'
require 'yaml'

class CommandCenter < Sinatra::Application
  configure do
    Projectify.configure do |config|
      addresses = YAML.load_file("config/projector_addresses.yml") || begin
        puts "WARNING: No projector addresses were found in `projector_addresses.yml`.  Add all projector IP or local addresses in this file."
        addresses = []
      end
      config.projector_addresses = addresses
    end
  end

  get '/' do
    broadcaster = Projectify::Broadcaster.new

    @powered_on = !!(broadcaster.any?(:powered_on?) || broadcaster.any?(:warming_up?))
    @number_projectors = broadcaster.projectors.size
    if broadcaster.any?(:power_transitioning?)
      @meta_refresh_interval = 2 #seconds
    end

    haml :dashboard
  end

  post '/power_on' do
    Projectify::Broadcaster.new.call(:power_on)
  end

  post '/power_off' do
    Projectify::Broadcaster.new.call(:power_off)
  end
end