require "json"

module Job

  class Base
    def initialize(request, queue, socket)
      @request = request
      @queue, @socket = queue, socket
    end
  end


  class NullObject < Base
    def run
    end
  end


  class Ping < Base
    def run
      @socket.send("PONG", 0, @request.sender_address, @request.sender_port)
    end
  end


  class Send < Base
    def run
      @request.mesg_rest.match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
      json = JSON.generate({
                               "registration_ids" => [$1],
                               "data"             => {"alert" => $2}
                           })
      @queue << json
    end
  end

end


module JobFactory

  JOB_FOR_INCOMING_REQUEST = {
    'PING' => Job::Ping,
    'SEND' => Job::Send
  }
  JOB_FOR_INCOMING_REQUEST.default = Job::NullObject

  def self.find_job_for_incoming_request(request, queue, socket)
    JOB_FOR_INCOMING_REQUEST[request.verb].new(request, queue, socket)
  end

end
