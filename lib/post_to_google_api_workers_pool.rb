require 'httpclient'
require 'thread'

class PostToGoogleApiWorkersPool

  attr_reader :queue

  def initialize(nof_workers)
    @nof_workers = nof_workers

    start
  end

#------------------------------------------------------------------------------
  private

    def start
      @queue  = Queue.new
      @client = HTTPClient.new
      @nof_workers.times do
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
