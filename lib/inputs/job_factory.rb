require_relative 'notification_request'
require 'job'

class JobFactory

  def self.from_raw_message(raw_data)
    request = NotificationRequest.from(raw_data)

    job_class = JOB_FOR_VERB[request.verb]
    job_class.new(request)
  end

private

  JOB_FOR_VERB = {
     'PING' => Job::Ping,
     'SEND' => Job::Send,
   }
  JOB_FOR_VERB.default = Job::NullJob

end
