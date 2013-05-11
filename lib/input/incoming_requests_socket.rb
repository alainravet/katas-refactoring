class IncomingRequestsSocket < UDPSocket

  def initialize(address, port)
    super()
    bind(address, port)
  end

end
