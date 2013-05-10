require "json"
require "socket"

$:.unshift File.dirname(__FILE__)
require 'google_api_worker'
require 'listener'

class PushDaemon
  DEFAULT_NOF_WORKERS = 10
  DEFAULT_PORT        = 6889

  def start
    worker   = GoogleApiWorker.new(DEFAULT_NOF_WORKERS)
    listener = Listener.new(DEFAULT_PORT)
    process_requests(self, listener, worker)
  end

  def call(data, socket, worker)
    case data[0].split.first
      when "PING"
        socket.send("PONG", 0, data[1][3], data[1][1])
      when "SEND"
        data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
        json = JSON.generate({
                                 "registration_ids" => [$1],
                                 "data"             => {"alert" => $2}
                             })
        worker.queue << json
    end
  end

#------------------------------------------------------------------------------
private

  def process_requests(zelf, listener, worker)
    socket = listener.socket
    while data = socket.recvfrom(maxlen=4096)
      zelf.call(data, socket, worker)
    end
  end

end
