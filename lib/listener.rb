class Listener

  attr_reader :socket

  def initialize(port)
    @socket = UDPSocket.new
    bind(port)
  end

private

  def bind(port)
    @socket.bind("0.0.0.0", port)
  end

end
