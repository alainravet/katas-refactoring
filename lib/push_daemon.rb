require "json"
require "thread"
require "httpclient"
require "socket"

APP_CONFIG = {
  :API_KEY        => 'AIzaSyCABSTd47XeIH',

  :LISTENING_PORT => 6889,
  :POOL_SIZE      => 10,
}

require_relative 'data_types_and_utils'

class PushDaemon
  include Utils

  def initialize
    jobs_queue  = Queue.new
    api_client  = HTTPClient.new
    incoming_requests_source = UDPSocket.new

    APP_CONFIG[:POOL_SIZE].times do
      Thread.new do
        on_notification_to_post(jobs_queue) do |notification_text|
          api_client.post("https://android.googleapis.com/gcm/send", notification_text, {
            "Authorization" => "key=#{APP_CONFIG[:API_KEY]}",
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
