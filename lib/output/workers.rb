require "thread"
require "httpclient"

class PoolOfSendNotificationRequestWorkers

  def initialize(queue, pool_size, api_key)
    @queue, @pool_size, @api_key = queue, pool_size, api_key
  end

  def start
    @pool_size.times do
      Thread.new { wait_for_and_perform_task.call }
    end
  end

  def wait_for_and_perform_task
    -> do
      on_new_job(@queue) do |job_class, data|
        job_class.call(worker_locals, data)
      end
    end
  end

  #-----------------------------------------------------------------------------
  private

    def on_new_job(queue)
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
