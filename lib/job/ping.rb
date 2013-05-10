# encoding: utf-8

module Job

  class Ping
    def initialize(raw_data, port_binder)
      @raw_data, @port_binder = raw_data, port_binder
    end

    def run
      @port_binder.socket.send("PONG", 0, @raw_data[1][3], @raw_data[1][1])
    end
  end

end
