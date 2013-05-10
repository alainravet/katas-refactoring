# encoding: utf-8

require 'json'

class Job::Send

  def initialize(raw_data, worker)
    @raw_data, @worker= raw_data, worker
  end

  def run
    @raw_data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
    json = JSON.generate({
                             "registration_ids" => [$1],
                             "data"             => {"alert" => $2}
                         })
    @worker.queue << json
  end

end
