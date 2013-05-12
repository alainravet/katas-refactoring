require_relative 'output/workers'
require_relative 'output/jobs'
require_relative 'input/incoming_requests_socket'

class PushDaemon

  def initialize(api_key, port: 6889, pool_size:10)
    socket = IncomingRequestsSocket.new("0.0.0.0", port)
    queue  = Queue.new
    PoolOfSendNotificationRequestWorkers.
        new(queue, pool_size, api_key).
        start
    wait_for_and_process_incoming_requests(socket, queue)
  end

  private

  include SimpleSocketEventer

    def wait_for_and_process_incoming_requests(socket, queue)
      on_incoming_request(socket) do |request|
        job = JobFactory.find_job_for_incoming_request(request, queue, socket)
        job.run
      end
    end

end
