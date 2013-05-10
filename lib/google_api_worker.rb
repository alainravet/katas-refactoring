require 'httpclient'
require 'thread'

class GoogleApiWorker

  attr_reader :queue

  def initialize(nof_workers)
    @queue  = Queue.new
    @client = HTTPClient.new
    spawn(nof_workers)
  end

#------------------------------------------------------------------------------
private

  def spawn(nof_workers)
    nof_workers.times do
      Thread.new do
        while data = queue.pop
          @client.post("https://android.googleapis.com/gcm/send", data, {
              "Authorization" => "key=AIzaSyCABSTd47XeIH",
              "Content-Type"  => "application/json"
          })
        end
      end
    end
  end

end
