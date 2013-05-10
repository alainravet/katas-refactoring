# encoding: utf-8

require 'json'

class Job::Send

  def initialize(command_line_tokens, _, worker)
    @command_line_tokens = command_line_tokens
    @worker = worker
  end

  def run
    api_token = @command_line_tokens.rest[0]
    msg       = @command_line_tokens.rest[1]
    json = JSON.generate({
                             "registration_ids" => [api_token],
                             "data"             => {"alert" => msg}
                         })
    @worker.queue << json
  end

end
