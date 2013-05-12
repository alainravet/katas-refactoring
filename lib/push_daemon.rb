require "json"
require "thread"
require "httpclient"
require "socket"

class PushDaemon

  def initialize
    jobs_queue    = Queue.new
    client_to_api = HTTPClient.new
    incoming_requests_source = UDPSocket.new

    10.times do
      Thread.new do
        while data = jobs_queue.pop
          client_to_api.post("https://android.googleapis.com/gcm/send", data, {
            "Authorization" => "key=AIzaSyCABSTd47XeIH",
            "Content-Type" => "application/json"
          })
        end
      end
    end

    incoming_requests_source.bind("0.0.0.0", 6889)

    while req = incoming_requests_source.recvfrom(4096)
      msg, sender_addrinfo = *req
      msg_verb = msg.split.first
      msg_rest = msg[5..-1]

      case msg_verb
      when "PING"
        sender_ip_address = sender_addrinfo[3]
        sender_port       = sender_addrinfo[1]
        incoming_requests_source.send("PONG", 0, sender_ip_address, sender_port)
      when "SEND"
        msg_rest.match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        registration_id   = $1
        notification_text = $2
        notification_post_job_payload = JSON.generate({
          "registration_ids" => [registration_id],
          "data" => { "alert" => notification_text}
        })
        jobs_queue << notification_post_job_payload
      end
    end
  end

end
