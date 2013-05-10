$:.unshift File.dirname(__FILE__)
require 'google_api_worker'
require 'port_binder'
require 'commands_catcher'
require 'job'
require 'command_factory'

class PushDaemon
  DEFAULT_NOF_WORKERS = 10
  DEFAULT_PORT        = 6889

  def initialize(port: DEFAULT_PORT, nof_workers: DEFAULT_NOF_WORKERS)
    @port         = port
    @nof_workers  = nof_workers
  end

  def start
    @worker      = GoogleApiWorker.new(@nof_workers)
    @port_binder = PortBinder.new(@port)
    CommandsCatcher.new(self).listen_on(@port_binder)
  end

  attr_reader :worker, :port_binder

  def call(data)
    command = CommandFactory.from_raw_message(data)
    command.run(self)
  end

end
