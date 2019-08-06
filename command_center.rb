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
    @powered_on = powered_on?
    @shutter_open = shutter_open?
    @number_projectors = broadcaster.projectors.size
    haml :dashboard
  end

  post '/power_on' do
    Projectify::Broadcaster.new.call(:power_on)
  end

  post '/power_off' do
    Projectify::Broadcaster.new.call(:power_off)
  end

  post '/shutter_open' do
    Projectify::Broadcaster.new.call(:shutter_open)
  end

  post '/shutter_close' do
    Projectify::Broadcaster.new.call(:shutter_close)
  end

  get '/stream', provides: 'text/event-stream' do
    stream :keep_open do |out|
      EM.add_periodic_timer(3) do
        data = {
          powered_on: powered_on?,
          shutter_open: shutter_open?,
        }
        out << "data: #{data.to_json}\n\n"
      end
    end
  end


  private

  def broadcaster
    @broadcaster ||= Projectify::Broadcaster.new
  end

  def powered_on?
    !!(broadcaster.all?(:powered_on?) || broadcaster.any?(:busy?) || broadcaster.any?(:warming_up?))
  end

  def shutter_open?
    !!(broadcaster.all?(:shutter_open?) && powered_on?)
  end

end