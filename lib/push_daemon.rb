require "json"
require "socket"

require_relative 'output/workers'
require_relative 'output/jobs'
require_relative 'input/incoming_requests_socket'

class PushDaemon

  def initialize
    socket = IncomingRequestsSocket.new("0.0.0.0", 6889)
    queue  = Queue.new
    PoolOfSendNotificationRequestWorkers.
        new(queue, 10).
        start
    wait_for_and_process_incoming_requests(queue, socket)
  end

  private


  def wait_for_and_process_incoming_requests(queue, socket)

      while data = socket.recvfrom(4096)
        mesg, sender_addrinfo = *data
        case mesg.split.first
          when "PING" then Job::Ping.new(mesg, sender_addrinfo, queue, socket).run
          when "SEND" then Job::Send.new(mesg, sender_addrinfo, queue, socket).run
        end
      end
    end

end
