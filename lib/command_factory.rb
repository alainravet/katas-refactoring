AddressParts = Struct.new(:prot, :port, :addr, :addr_2)

CommandLine  = Struct.new(:tokens) do
  def verb ; tokens.first  end
  def rest ; tokens[1..-1] end
end


class CommandFactory

  def self.from(data)
    command_line  = CommandLine.new(Shellwords.shellsplit(data[0]))
    address_parts = AddressParts.new(*data[1])

    command = COMMAND_FOR_VERB[command_line.verb].new(command_line, address_parts)
  end

private

  COMMAND_FOR_VERB = {
     'PING' => Job::Ping,
     'SEND' => Job::Send,
   }
  COMMAND_FOR_VERB.default = Job::NullJob

end

# data =
#   ["PING", ["AF_INET", 55560, "127.0.0.1", "127.0.0.1"]]
#   ["SEND t0k3n \"Steve: What is up?\"", ["AF_INET", 55053, "127.0.0.1", "127.0.0.1"]]
