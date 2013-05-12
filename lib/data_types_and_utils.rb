
module DataTypes

  # wrap and smartify input data like :
  #     ["PING",                       ["AF_INET", 53794, "127.0.0.1", "127.0.0.1"]]
  #       ^^^^                                     ^^^^^               ^^^^^^^^^^^
  #       verb                                     port                 ip address
  #     ["SEND t0k3n \"Hello World\"", ["AF_INET", 62139, "127.0.0.1", "127.0.0.1"]]
  #            ^^^^^   ^^^^^^^^^^^
  IncomingRequest = Struct.new(:message, :sender_addrinfo) do
    def msg_verb          ; message.split.first end   # 'PING', 'SEND'
    def msg_rest          ; message[5..-1]      end   # 'Hello World'
    def sender_port       ; sender_addrinfo[1]  end   # 62139
    def sender_ip_address ; sender_addrinfo[3]  end   # '127.0.0.1'
  end

end

#-------------------------------------------------------------------------------

module Utils
  include DataTypes

  def on_notification_to_post(queue)
    while notification_text = queue.pop
      yield notification_text
    end
  end

  def on_incoming_request(socket)
    while data = socket.recvfrom(4096)
      mesg, sender_addrinfo = *data
      yield IncomingRequest.new(mesg, sender_addrinfo)
    end
  end
end

