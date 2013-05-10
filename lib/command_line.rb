require 'shellwords'

class CommandLine  < Struct.new(:tokens)

  def self.from_socket_message(data)
    new(Shellwords.shellsplit(data[0]))
  end

  #----------------------------------------------------------------------------
  # QUERIES :
  #----------------------------------------------------------------------------

  def verb ; tokens.first  end
  def rest ; tokens[1..-1] end

end
