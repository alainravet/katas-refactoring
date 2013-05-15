require "json"
require "thread"
require "httpclient"
require "socket"

def on_new_input_request(socket)
  while data = socket.recvfrom(4096)
    yield data
  end
end
def on_new_job_request(queue)
  while data = queue.pop
    yield data
  end
end
def worker
  Thread.new do
    yield
  end
end

def create_pool_of(size)
  size.times do
    yield
  end
end

class PushDaemon

  def initialize
    create_pool_of(10) do
      worker do
        on_new_job_request(jobs_queue) do |data|
          perform_send_notification_request(data)
        end
      end
    end

    incoming_request_source = UDPSocket.new
    incoming_request_source.bind("0.0.0.0", 6889)

    on_new_input_request(incoming_request_source) do |data|
      dispatch_work(data, jobs_queue, incoming_request_source)
    end
  end





  def jobs_queue
    @_jobs_queue ||= Queue.new
  end


    def dispatch_work(data, queue, socket)
      case data[0].split.first
        when "PING" then perform_reply_with_pong(data, socket)
        when "SEND" then enqueue_request_for_notification(data, queue)
      end
    end

      def perform_reply_with_pong(data, socket)
        socket.send("PONG", 0, data[1][3], data[1][1])
      end

      def perform_send_notification_request(data)
        client = HTTPClient.new
        client.post("https://android.googleapis.com/gcm/send", data, {
            "Authorization" => "key=AIzaSyCABSTd47XeIH",
            "Content-Type"  => "application/json"
        })
      end

      def enqueue_request_for_notification(data, queue)
        data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        json = JSON.generate({
                                 "registration_ids" => [$1],
                                 "data"             => {"alert" => $2}
                             })
        queue << json
      end


end
