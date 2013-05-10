$:.unshift File.dirname(__FILE__)
require 'google_api_worker'
require 'port_binder'
require 'commands_catcher'
require 'job'
require 'shellwords'

class PushDaemon
  DEFAULT_NOF_WORKERS = 10
  DEFAULT_PORT        = 6889

  def start
    @worker   = GoogleApiWorker.new(DEFAULT_NOF_WORKERS)
    @port_binder = PortBinder.new(DEFAULT_PORT)
    CommandsCatcher.new(self).listen(@port_binder)
  end

  AddressParts = Struct.new(:prot, :port, :addr, :addr_2)

  CommandLine  = Struct.new(:tokens) do
    def verb ; tokens.first  end
    def rest ; tokens[1..-1] end
  end



  COMMAND_FOR_VERB = {
     'PING' => Job::Ping,
     'SEND' => Job::Send,
   }
  COMMAND_FOR_VERB.default = Job::NullJob

  def call(data)
    # data =
    #   ["PING", ["AF_INET", 55560, "127.0.0.1", "127.0.0.1"]]
    #   ["SEND t0k3n \"Steve: What is up?\"", ["AF_INET", 55053, "127.0.0.1", "127.0.0.1"]]
    command_line  = CommandLine.new(Shellwords.shellsplit(data[0]))
    address_parts = AddressParts.new(*data[1])

    COMMAND_FOR_VERB[command_line.verb].
        new(command_line, address_parts).
        run(@port_binder, @worker)

  end

end
