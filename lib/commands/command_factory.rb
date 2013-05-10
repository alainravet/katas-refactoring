require_relative 'notification_request'
require 'job'

class CommandFactory

  def self.from_raw_message(raw_data)
    request = NotificationRequest.from(raw_data)

    command_class = COMMAND_FOR_VERB[request.verb]
    command_class.new(request)
  end

private

  COMMAND_FOR_VERB = {
     'PING' => Job::Ping,
     'SEND' => Job::Send,
   }
  COMMAND_FOR_VERB.default = Job::NullJob

end
