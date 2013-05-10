require 'httpclient'
require 'thread'

class PostToGoogleApiWorkersPool

  attr_reader :queue

  def initialize(nof_workers)
    @nof_workers = nof_workers
    @queue  = Queue.new

    create_and_start_workers
  end

#------------------------------------------------------------------------------
  private

    def create_and_start_workers
      client = HTTPClient.new
      @nof_workers.times do
        create_and_start_worker(@queue, client)
      end
    end

    def create_and_start_worker(queue, client)
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
