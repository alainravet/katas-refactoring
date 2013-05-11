# encoding: utf-8

require 'json'

class Job::Send < Job::Base

  def run(context)
    api_token = command_line_tokens.rest[0]
    msg       = command_line_tokens.rest[1]
    json = JSON.generate({
                             "registration_ids" => [api_token],
                             "data"             => {"alert" => msg}
                         })
    context.queue << json
  end

end
