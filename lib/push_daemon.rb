$:.unshift File.dirname(__FILE__)
require 'workers/post_to_google_api_workers_pool'
require 'port_binder'
require 'socket_eventer'
require 'job/job_factory'

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
  include SocketEventer

  def start
    start_the_workers_pool()

    @port_binder = PortBinder.new(@port)

    on_new_data(@port_binder.socket) do |data|
      job = JobFactory.from_raw_message(data)
      job.run(self)
    end
  end

  private
    def start_the_workers_pool
      @workers_pool = PostToGoogleApiWorkersPool.new(@nof_workers)
    end
  public

end
