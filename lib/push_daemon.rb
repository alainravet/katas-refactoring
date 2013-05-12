require "json"
require "thread"
require "httpclient"
require "socket"

APP_CONFIG = {
  :API_KEY        => 'AIzaSyCABSTd47XeIH',

  :LISTENING_PORT => 6889,
  :POOL_SIZE      => 10,
}

class PushDaemon

  def initialize
    queue  = Queue.new
    client = HTTPClient.new
    socket = UDPSocket.new

    APP_CONFIG[:POOL_SIZE].times do
      Thread.new do
        api_key = APP_CONFIG[:API_KEY]
        while data = queue.pop
          client.post("https://android.googleapis.com/gcm/send", data, {
            "Authorization" => "key=#{api_key}",
            "Content-Type" => "application/json"
          })
        end
      end
    end

    socket.bind("0.0.0.0", APP_CONFIG[:LISTENING_PORT])

    while data = socket.recvfrom(4096)
      case data[0].split.first
      when "PING"
        socket.send("PONG", 0, data[1][3], data[1][1])
      when "SEND"
        data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        json = JSON.generate({
          "registration_ids" => [$1],
          "data" => { "alert" => $2 }
        })
        queue << json
      end
    end
  end

end
