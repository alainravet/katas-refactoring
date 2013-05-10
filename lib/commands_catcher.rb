class CommandsCatcher

  def initialize(app, port_binder)
    @callback_target  = app
    @port_binder      = port_binder
  end

  def wait_for_commands
    socket = @port_binder.socket
    while data = socket.recvfrom(maxlen=4096)
      @callback_target.call(data)
    end
  end

end
