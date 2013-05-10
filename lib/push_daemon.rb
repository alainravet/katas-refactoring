$:.unshift File.dirname(__FILE__)
require 'post_to_google_api_workers_pool'
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

  #-----------------------------------------------------------------------------
  # QUERIES :
  #-----------------------------------------------------------------------------

  attr_reader :workers_pool, :port_binder

  #-----------------------------------------------------------------------------
  # COMMANDS :
  #-----------------------------------------------------------------------------

  def start
    start_the_workers_pool()
    start_waiting_for_commands()
  end

  private
    def start_the_workers_pool
      @workers_pool = PostToGoogleApiWorkersPool.new(@nof_workers)
    end

    def start_waiting_for_commands
      @port_binder = PortBinder.new(@port)
      CommandsCatcher.new(self, @port_binder).wait_for_commands
    end
  public

  #-----------------------------------------------------------------------------
  # CALLBACK :
  #-----------------------------------------------------------------------------

  def call(data)
    command = CommandFactory.from_raw_message(data)
    command.run(self)
  end

end
