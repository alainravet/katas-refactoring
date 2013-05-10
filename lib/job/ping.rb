# encoding: utf-8

module Job

  class Ping
    def initialize(command_line_tokens, address_parts, port_binder, _)
      @port_binder = port_binder
      _, @address_parts       = command_line_tokens, address_parts
    end

    def run
      address = @address_parts.addr
      port    = @address_parts.port
      @port_binder.socket.send("PONG", 0, address, port)
    end
  end

end
