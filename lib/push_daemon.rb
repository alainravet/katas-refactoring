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
      find_job_for_incoming_request(mesg, sender_addrinfo, queue, socket).
          run
    end
  end

  def find_job_for_incoming_request(mesg, sender_addrinfo, queue, socket)
    job = case mesg.split.first
      when "PING" then Job::Ping.new(mesg, sender_addrinfo, queue, socket)
      when "SEND" then Job::Send.new(mesg, sender_addrinfo, queue, socket)
      else
        Job::NullObject.new(mesg, sender_addrinfo, queue, socket)
    end
  end

end
