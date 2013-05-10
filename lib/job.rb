module Job
  class NullJob
    def initialize(_, _, _, _)
    end
    def run ; end
  end
end

require_relative 'job/ping'
require_relative 'job/send'
