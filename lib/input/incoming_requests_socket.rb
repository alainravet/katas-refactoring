require "socket"

class IncomingRequestsSocket < UDPSocket

  def initialize(address, port)
    super()
    bind(address, port)
  end

end

module SimpleSocketEventer

  def on_incoming_request(socket)
    while data = socket.recvfrom(maxlen=4096)
      mesg, sender_addrinfo = *data
      yield mesg, sender_addrinfo
    end
  end

end
