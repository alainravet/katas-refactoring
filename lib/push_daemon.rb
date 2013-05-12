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
      case req[0].split.first
      when "PING"
        incoming_requests_source.send("PONG", 0, req[1][3], req[1][1])
      when "SEND"
        req[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        notification_post_job_payload = JSON.generate({
          "registration_ids" => [$1],
          "data" => { "alert" => $2 }
        })
        jobs_queue << notification_post_job_payload
      end
    end
  end

end
