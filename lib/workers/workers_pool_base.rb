class WorkersPoolBase

  def initialize(nof_workers)
    @queue       = Queue.new    # exported
    create_and_start_workers(nof_workers)
  end

  attr_reader :queue

end
