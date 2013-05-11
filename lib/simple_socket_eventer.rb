module SimpleSocketEventer

  def on_new_data(socket, maxlen:4096)
    while data = socket.recvfrom(maxlen)
      yield data
    end
  end

end
