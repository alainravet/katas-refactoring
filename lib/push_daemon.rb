$:.unshift File.dirname(__FILE__)
require 'google_api_worker'
require 'port_binder'
require 'commands_catcher'
require 'job'
require 'command_factory'
require 'shellwords'

class PushDaemon
  DEFAULT_NOF_WORKERS = 10
  DEFAULT_PORT        = 6889

  def start
    @worker   = GoogleApiWorker.new(DEFAULT_NOF_WORKERS)
    @port_binder = PortBinder.new(DEFAULT_PORT)
    CommandsCatcher.new(self).listen(@port_binder)
  end

  attr_reader :worker, :port_binder

  def call(data)
    command = CommandFactory.from(data)
    command.run(self)
  end

end
