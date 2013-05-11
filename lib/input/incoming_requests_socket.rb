require "socket"

class IncomingRequestsSocket < UDPSocket

  def initialize(address, port)
    super()
    bind(address, port)
  end

end

class IncomingRequest < Struct.new(:mesg, :sender_addrinfo)
  def verb           ; mesg.split.first           end
  def mesg_rest      ; mesg[(verb.length+1)..-1]  end
  def sender_port    ; sender_addrinfo[1]         end
  def sender_address ; sender_addrinfo[3]         end
end

module SimpleSocketEventer


  def on_incoming_request(socket)
    while data = socket.recvfrom(maxlen=4096)
      mesg, sender_addrinfo = *data
      yield IncomingRequest.new(mesg, sender_addrinfo)
    end
  end

end
