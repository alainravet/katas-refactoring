require 'shellwords'

class CommandLine  < Struct.new(:tokens)

  #----------------------------------------------------------------------------
  # QUERIES :
  #----------------------------------------------------------------------------

  def verb ; tokens.first  end
  def rest ; tokens[1..-1] end

end
