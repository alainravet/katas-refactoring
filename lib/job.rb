module Job

  class Base
    def initialize(request)
      @request = request
    end

    def command_line_tokens ; @request.raw_command    end
    def address_parts       ; @request.address_parts  end
  end


  class NullJob < Base
    def run(_) ; end
  end

end

require_relative 'job/ping'
require_relative 'job/send'
