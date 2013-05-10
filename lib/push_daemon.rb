$:.unshift File.dirname(__FILE__)
require 'google_api_worker'
require 'port_binder'
require 'commands_catcher'
require 'job'

class PushDaemon
  DEFAULT_NOF_WORKERS = 10
  DEFAULT_PORT        = 6889

  def start
    @worker   = GoogleApiWorker.new(DEFAULT_NOF_WORKERS)
    @port_binder = PortBinder.new(DEFAULT_PORT)
    CommandsCatcher.new(self).listen(@port_binder)
  end

  def call(data)
    case data[0].split.first
      when "PING"
        Job::Ping.new(data, @port_binder).run
      when "SEND"
        Job::Send.new(data, @worker).run
    end
  end

end

# Data clump problem :
# data =
#   ["PING", ["AF_INET", 55560, "127.0.0.1", "127.0.0.1"]]
#   ["SEND t0k3n \"Steve: What is up?\"", ["AF_INET", 55053, "127.0.0.1", "127.0.0.1"]]
#
# require 'shellwords'
# Shellwords.shellsplit(data.first)  - http://www.ruby-doc.org/stdlib-1.9.3/libdoc/shellwords/rdoc/index.html
#   >>["PING"]
#   >>["SEND", "t0k3n", "Steve: What is up?"]
#
# require 'socket'
# ai = Addrinfo.new(["AF_INET", 55053, "127.0.0.1", "127.0.0.1"])
# ai.inspect # => "#<Addrinfo: 127.0.0.1:55053>"
