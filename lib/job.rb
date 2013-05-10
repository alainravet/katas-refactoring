module Job

  class Base
    def initialize(command_line_tokens, address_parts)
      @command_line_tokens = command_line_tokens
      @address_parts       = address_parts
    end
  end

  class NullJob < Base
    def run(_,_) ; end
  end

end

require_relative 'job/ping'
require_relative 'job/send'
