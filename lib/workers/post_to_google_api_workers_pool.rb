require 'httpclient'

require_relative 'workers_pool_base'
require_relative 'post_to_google_api_worker'

class PostToGoogleApiWorkersPool < WorkersPoolBase

  def create_and_start_workers(nof_workers)
    client = HTTPClient.new
    nof_workers.times do
      PostToGoogleApiWorker.new(@queue, client)
    end
  end

end