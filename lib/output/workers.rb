require "thread"
require "httpclient"

class PoolOfSendNotificationRequestWorkers

  def initialize(queue, pool_size, api_key)
    @queue, @pool_size, @api_key = queue, pool_size, api_key
  end

  def start
    @pool_size.times do
      Thread.new do
        on_notification_request(@queue) do |job_class, data|
          job_class.call(worker_locals, data)
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  private

    def on_notification_request(queue)
      while job_description = queue.pop
        job_class, data = *job_description
        yield job_class, data
      end
    end

    WorkerContext = Struct.new(:queue, :pool_size, :api_key, :shared_client)

    def worker_locals
      @shared_client ||= HTTPClient.new
      WorkerContext.new(@queue, @pool_size, @api_key, @shared_client)
    end

end
