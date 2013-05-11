require "thread"
require "httpclient"

class PoolOfSendNotificationRequestWorkers

  def initialize(queue, pool_size, api_key)
    @queue, @pool_size, @api_key = queue, pool_size, api_key
  end

  def start
    shared_client = HTTPClient.new
    @pool_size.times do
      Thread.new do
        while data = @queue.pop
          shared_client.post("https://android.googleapis.com/gcm/send", data, {
              "Authorization" => "key=" + @api_key ,
              "Content-Type"  => "application/json"
          })
        end
      end
    end
  end

end
