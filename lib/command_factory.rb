require_relative 'command_line'
require_relative 'address_parts'

class CommandFactory

  # data =
  #   ["PING", ["AF_INET", 55560, "127.0.0.1", "127.0.0.1"]]
  #   ["SEND t0k3n \"Steve: What is up?\"", ["AF_INET", 55053, "127.0.0.1", "127.0.0.1"]]
  #
  def self.from_socket_message(data)
    command_line  = CommandLine.new(Shellwords.shellsplit(data[0]))
    address_parts = AddressParts.new(*data[1])

    command_class = COMMAND_FOR_VERB[command_line.verb]
    command_class.new(command_line, address_parts)
  end

private

  COMMAND_FOR_VERB = {
     'PING' => Job::Ping,
     'SEND' => Job::Send,
   }
  COMMAND_FOR_VERB.default = Job::NullJob

end
