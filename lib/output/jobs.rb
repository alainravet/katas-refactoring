require "json"

module Job

  class Base
    def initialize(request, queue, socket)
      @request = request
      @queue, @socket = queue, socket
    end

    def self.shared_out_socket
      @@_shared_out_socket ||= UDPSocket.new
    end
  end


  class NullObject < Base
    def run
    end
  end


  # Synchronous version :
  #class Ping < Base
  #  def run
  #    @socket.send("PONG", 0, @request.sender_address, @request.sender_port)
  #  end
  #end

  # Asynchronous version :
  class Ping < Base
    def run
      @queue << [Job::Ping, data=[@request.sender_address, @request.sender_port]]
    end

    # Async callback (by a worker):
    def self.call(_, data)
      sender_address, sender_port = *data
      shared_out_socket.send("PONG", 0, sender_address, sender_port)
    end
  end


  class Send < Base
    def run
      @request.mesg_rest.match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
      json = JSON.generate({
                               "registration_ids" => [$1],
                               "data"             => {"alert" => $2}
                           })
      @queue << [Job::Send, data=json]
    end

    # Async callback (by a worker):
    def self.call(worker_context, data)
      c = worker_context
      c.shared_client.post("https://android.googleapis.com/gcm/send", data, {
          "Authorization" => "key=" + c.api_key ,
          "Content-Type"  => "application/json"
      })
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
