# encoding: utf-8

module Job

  class Ping < Job::Base

    def run(context)
      address = address_parts.addr
      port    = address_parts.port
      context.port_binder.socket.send("PONG", 0, address, port)
    end

  end

end
