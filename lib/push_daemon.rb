require "json"
require "thread"
require "httpclient"
require "socket"

class PushDaemon

  def initialize(api_auth_token)
    queue  = Queue.new
    start_pool_of__wait_for_internal_notification_request_and_post_to_google_notifier__workers(queue, 10, api_auth_token)
    socket = listening_socket_for_internal_notifications_requests("0.0.0.0", 6889)
    wait_for_and_process_external_notifications_requests(queue, socket)
  end

  #-----------------------------------------------------------------------------
  private

    def start_pool_of__wait_for_internal_notification_request_and_post_to_google_notifier__workers(queue, pool_size, api_auth_token)
      client = HTTPClient.new
      pool_size.times do
        create_and_start_a__wait_for_internal_notification_request_and_post_to_google_notifier__worker(client, queue, api_auth_token)
      end
    end

      def create_and_start_a__wait_for_internal_notification_request_and_post_to_google_notifier__worker(client, queue, api_auth_token)
        Thread.new do
          wait_for_internal_notification_request_and_post_to_google_action(queue, client, api_auth_token)
        end
      end

        def wait_for_internal_notification_request_and_post_to_google_action(queue, client, api_auth_token)
          while data = queue.pop
            send_external_notification_request_to_google_notifier(client, data, api_auth_token)
          end
        end

          def send_external_notification_request_to_google_notifier(client, data, api_auth_token)
            client.post("https://android.googleapis.com/gcm/send", data, {
                "Authorization" => "key=#{api_auth_token}",
                "Content-Type"  => "application/json"
            })
          end


    def listening_socket_for_internal_notifications_requests(address, port)
      socket = UDPSocket.new
      socket.bind(address, port)
      socket
    end


    def wait_for_and_process_external_notifications_requests(queue, socket)
      while data = socket.recvfrom(4096)
        case data[0].split.first
          when "PING"
            react_to_ping_external_request(data, socket)
          when "SEND"
            react_to_send_external_request(data, queue)
        end
      end
    end

      def react_to_ping_external_request(data, socket)
        socket.send("PONG", 0, data[1][3], data[1][1])
      end

      def react_to_send_external_request(data, queue)
        data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        json = JSON.generate({
                                 "registration_ids" => [$1],
                                 "data"             => {"alert" => $2}
                             })
        queue << json
      end

end
