require 'job'

class JobFactory

  def self.for_request(request)
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
