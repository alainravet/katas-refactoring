require "json"
require "thread"
require "httpclient"
require "socket"

class PushDaemon

  def initialize
    queue  = Queue.new
    start_pool_of__post_to_google_notifier__workers(queue, 10)
    socket = listening_socket_for_incoming_requests("0.0.0.0", 6889)
    wait_for_and_process_incoming_requests(queue, socket)
  end

  #-----------------------------------------------------------------------------
  private

    def start_pool_of__post_to_google_notifier__workers(queue, pool_size)
      client = HTTPClient.new
      pool_size.times do
        Thread.new do
          while data = queue.pop
            client.post("https://android.googleapis.com/gcm/send", data, {
                "Authorization" => "key=AIzaSyCABSTd47XeIH",
                "Content-Type"  => "application/json"
            })
          end
        end
      end
    end

    def listening_socket_for_incoming_requests(address, port)
      socket = UDPSocket.new
      socket.bind(address, port)
      socket
    end

    def wait_for_and_process_incoming_requests(queue, socket)
      while data = socket.recvfrom(4096)
        case data[0].split.first
          when "PING"
            socket.send("PONG", 0, data[1][3], data[1][1])
          when "SEND"
            data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
            json = JSON.generate({
                                     "registration_ids" => [$1],
                                     "data"             => {"alert" => $2}
                                 })
            queue << json
        end
      end
    end

end
