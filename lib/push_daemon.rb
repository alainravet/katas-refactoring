$:.unshift File.dirname(__FILE__)
require 'workers/post_to_google_api_workers_pool'
require 'port_binder'
require 'simple_socket_eventer'
require 'job/job_factory'
require 'inputs/notification_request'

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

  #-----------------------------------------------------------------------------
  # COMMANDS :
  #-----------------------------------------------------------------------------
  include SimpleSocketEventer
  JobContext = Struct.new(:workers_pool, :port_binder)

  def start
    start_the_workers_pool()

    @port_binder = PortBinder.new(@port)

    on_new_data(@port_binder.socket) do |raw_data|
      request = NotificationRequest.from(raw_data)
      job     = JobFactory.for_request(request)
      context = JobContext.new(@workers_pool, @port_binder)  # what a job needs to know
      job.run context
    end
  end

  private
    def start_the_workers_pool
      @workers_pool = PostToGoogleApiWorkersPool.new(@nof_workers)
    end
  public

end
