class CommandsCatcher

  def initialize(app)
    @app = app
  end

  def listen(listener)
    socket = listener.socket
    while data = socket.recvfrom(maxlen=4096)
      @app.call(data)
    end
  end

end
