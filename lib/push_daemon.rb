$:.unshift File.dirname(__FILE__)
require 'google_api_worker'
require 'port_binder'
require 'commands_catcher'
require 'job'

class PushDaemon
  DEFAULT_NOF_WORKERS = 10
  DEFAULT_PORT        = 6889

  def start
    @worker   = GoogleApiWorker.new(DEFAULT_NOF_WORKERS)
    @port_binder = PortBinder.new(DEFAULT_PORT)
    CommandsCatcher.new(self).listen(@port_binder)
  end

  def call(data)
    case data[0].split.first
      when "PING"
        Job::Ping.new(data, @port_binder).run
      when "SEND"
        Job::Send.new(data, @worker).run
    end
  end

end
