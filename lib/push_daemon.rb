require "json"
require "socket"

$:.unshift File.dirname(__FILE__)
require 'google_api_worker'

class PushDaemon
  def initialize
    @queue  = Queue.new
    @socket = UDPSocket.new
  end

  def start
    worker = GoogleApiWorker.new(10, queue)
    bind_to
    process_requests
  end

#------------------------------------------------------------------------------
private
  attr_reader :queue, :socket

  def bind_to
    socket.bind("0.0.0.0", 6889)
  end

  def process_requests
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
          queue << json
      end
    end
  end

end
