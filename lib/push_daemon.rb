require "json"
require "thread"
require "httpclient"
require "socket"

APP_CONFIG = {
  :API_KEY        => 'AIzaSyCABSTd47XeIH',

  :LISTENING_PORT => 6889,
  :POOL_SIZE      => 10,
}

#-------------------------------------------------------------------------------

module DataTypes

  # wrap and smartify input data like :
  #     ["PING",                       ["AF_INET", 53794, "127.0.0.1", "127.0.0.1"]]
  #       ^^^^                                     ^^^^^               ^^^^^^^^^^^
  #       verb                                     port                 ip address
  #     ["SEND t0k3n \"Hello World\"", ["AF_INET", 62139, "127.0.0.1", "127.0.0.1"]]
  #            ^^^^^   ^^^^^^^^^^^
  IncomingRequest = Struct.new(:message, :sender_addrinfo) do
    def msg_verb          ; message.split.first end   # 'PING', 'SEND'
    def msg_rest          ; message[5..-1]      end   # 'Hello World'
    def sender_port       ; sender_addrinfo[1]  end   # 62139
    def sender_ip_address ; sender_addrinfo[3]  end   # '127.0.0.1'
  end

end

#-------------------------------------------------------------------------------

module Utils
  include DataTypes

  def on_notification_to_post(queue)
    while notification_text = queue.pop
      yield notification_text
    end
  end

  def on_incoming_request(socket)
    while data = socket.recvfrom(4096)
      mesg, sender_addrinfo = *data
      yield IncomingRequest.new(mesg, sender_addrinfo)
    end
  end
end

#-------------------------------------------------------------------------------

class PushDaemon
  include Utils

  def initialize
    jobs_queue  = Queue.new
    api_client  = HTTPClient.new
    incoming_requests_source = UDPSocket.new

    APP_CONFIG[:POOL_SIZE].times do
      Thread.new do
        api_key = APP_CONFIG[:API_KEY]
        on_notification_to_post(jobs_queue) do |notification_text|
          api_client.post("https://android.googleapis.com/gcm/send", notification_text, {
            "Authorization" => "key=#{api_key}",
            "Content-Type" => "application/json"
          })
        end
      end
    end

    incoming_requests_source.bind("0.0.0.0", APP_CONFIG[:LISTENING_PORT])

    on_incoming_request(incoming_requests_source) do |req|
      case req.msg_verb
      when "PING"
        incoming_requests_source.send("PONG", 0, req.sender_ip_address, req.sender_port)
      when "SEND"
        req.msg_rest.match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        registration_id   = $1
        notification_text = $2
        notification_to_post_details = JSON.generate({
          "registration_ids" => [registration_id],
          "data" => { "alert" => notification_text}
        })
        jobs_queue << notification_to_post_details
      end
    end
  end

end
