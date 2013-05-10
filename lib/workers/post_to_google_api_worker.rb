require 'thread'

class PostToGoogleApiWorker

  def initialize(queue, client)
    Thread.new do
      while data = blocking_get_data(queue)
        submit_notification_request(client, data)
      end
    end
  end

  private

    def blocking_get_data(queue)
      queue.pop
    end

    def submit_notification_request(client, data)
      client.post("https://android.googleapis.com/gcm/send", data, {
          "Authorization" => "key=AIzaSyCABSTd47XeIH",
          "Content-Type"  => "application/json"
      })
    end

end
