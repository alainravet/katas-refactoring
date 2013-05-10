require_relative 'raw_command'
require 'address_parts'

class NotificationRequest

  def initialize(raw_command, address_parts)
    @raw_command, @address_parts = raw_command, address_parts
  end
  private :initialize

  # data =
  #   ["PING", ["AF_INET", 55560, "127.0.0.1", "127.0.0.1"]]
  #   ["SEND t0k3n \"Steve: What is up?\"", ["AF_INET", 55053, "127.0.0.1", "127.0.0.1"]]
  #
  def self.from(raw_data)
    raw_command    = RawCommand.from_tokens(Shellwords.shellsplit(raw_data[0]))
    address_parts   = AddressParts.new(*raw_data[1])
    new(raw_command, address_parts)
  end

  #-----------------------------------------------------------------------------
  # QUERIES
  #-----------------------------------------------------------------------------

  attr_reader :raw_command, :address_parts

  def verb
    raw_command.verb
  end

end
