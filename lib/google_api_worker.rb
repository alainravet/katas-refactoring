require 'httpclient'
require 'thread'

class GoogleApiWorker

  def initialize(nof_workers, queue)
    client = HTTPClient.new
    nof_workers.times do
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

end
