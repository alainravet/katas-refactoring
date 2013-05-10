require 'command_line'
require 'address_parts'

class NotificationRequest

  def initialize(command_line, address_parts)
    @command_line, @address_parts = command_line, address_parts
  end
  private :initialize

  # data =
  #   ["PING", ["AF_INET", 55560, "127.0.0.1", "127.0.0.1"]]
  #   ["SEND t0k3n \"Steve: What is up?\"", ["AF_INET", 55053, "127.0.0.1", "127.0.0.1"]]
  #
  def self.from(raw_data)
    command_line    = CommandLine.from_tokens(Shellwords.shellsplit(raw_data[0]))
    address_parts   = AddressParts.new(*raw_data[1])
    new(command_line, address_parts)
  end

  #-----------------------------------------------------------------------------
  # QUERIES
  #-----------------------------------------------------------------------------

  attr_reader :command_line, :address_parts

  def verb
    command_line.verb
  end

end
