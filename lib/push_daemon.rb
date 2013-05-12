require "json"
require "thread"
require "httpclient"
require "socket"

APP_CONFIG = {
  :API_KEY        => 'AIzaSyCABSTd47XeIH',

  :LISTENING_PORT => 6889,
  :POOL_SIZE      => 10,
}
module Utils
  def on_notification_to_post(queue)
    while notification_text = queue.pop
      yield notification_text
    end
  end

  def on_incoming_request(socket)
    while data = socket.recvfrom(4096)
      mesg, sender_addrinfo = *data
      yield mesg, sender_addrinfo
    end
  end
end

class PushDaemon
  include Utils

  def initialize
    queue  = Queue.new
    client = HTTPClient.new
    socket = UDPSocket.new

    APP_CONFIG[:POOL_SIZE].times do
      Thread.new do
        api_key = APP_CONFIG[:API_KEY]
        on_notification_to_post(queue) do |notification_text|
          client.post("https://android.googleapis.com/gcm/send", notification_text, {
            "Authorization" => "key=#{api_key}",
            "Content-Type" => "application/json"
          })
        end
      end
    end

    socket.bind("0.0.0.0", APP_CONFIG[:LISTENING_PORT])

    on_incoming_request(socket) do |mesg, sender_addrinfo|
      msg_verb        = mesg.split.first # 'PING', 'SEND'
      msg_rest        = mesg[5..-1]
      sender_address  = sender_addrinfo[3]
      sender_port     = sender_addrinfo[1]

      case msg_verb
      when "PING"
        socket.send("PONG", 0, sender_address, sender_port)
      when "SEND"
        msg_rest.match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        registration_id   = $1
        notification_text = $2
        json = JSON.generate({
          "registration_ids" => [registration_id],
          "data" => { "alert" => notification_text}
        })
        queue << json
      end
    end
  end

end
