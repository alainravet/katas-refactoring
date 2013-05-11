module Job

  class Base
    def initialize(mesg, sender_addrinfo, queue, socket)
      @mesg, @sender_addrinfo, @queue, @socket = mesg, sender_addrinfo, queue, socket
    end
  end


  class Ping < Base
    def run
      @socket.send("PONG", 0, @sender_addrinfo[3], @sender_addrinfo[1])
    end
  end


  class Send < Base
    def run
      @mesg[5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
      json = JSON.generate({
                               "registration_ids" => [$1],
                               "data"             => {"alert" => $2}
                           })
      @queue << json
    end
  end

end
