require "json"
require "socket"

$:.unshift File.dirname(__FILE__)
require 'google_api_worker'

class PushDaemon
  def initialize
    @socket = UDPSocket.new
  end

  def start
    @worker = GoogleApiWorker.new(10)
    bind_to(@socket)
    process_requests(@socket)
  end

#------------------------------------------------------------------------------
private

  def bind_to(socket)
    socket.bind("0.0.0.0", 6889)
  end

  def process_requests(socket)
    while data = socket.recvfrom(4096)
      case data[0].split.first
        when "PING"
          socket.send("PONG", 0, data[1][3], data[1][1])
        when "SEND"
          data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
          json = JSON.generate({
                                   "registration_ids" => [$1],
                                   "data" => {"alert" => $2}
                               })
          @worker.queue << json
      end
    end
  end

end
