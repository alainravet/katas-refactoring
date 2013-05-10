class CommandsCatcher

  def initialize(app)
    @app = app
  end

  def listen_on(port_binder)
    socket = port_binder.socket
    while data = socket.recvfrom(maxlen=4096)
      @app.call(data)
    end
  end

end
