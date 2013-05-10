require 'shellwords'

class CommandLine  < Struct.new(:tokens)

  def self.from_tokens(tokens)
    new(tokens)
  end

  #----------------------------------------------------------------------------
  # QUERIES :
  #----------------------------------------------------------------------------

  def verb ; tokens.first  end
  def rest ; tokens[1..-1] end

end
