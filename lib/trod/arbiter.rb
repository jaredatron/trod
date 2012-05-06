class Trod::Arbiter < Trod::Command

  def run!
    start_redis_server
    report_status
    detect_tests
    start_workers
    report_status_until_complete
    shutdown
  end

  private

  #
  def start_redis_server
    report_event "starting redis server"
  end

  #
  def report_status
  end

  #
  def detect_tests
    report_event "detecting tests"
  end

  #
  def start_workers
    report_event "starting workers"
  end

  #
  def report_status_until_complete
    # TODO loop reporting state to S3 until all queues are empty & all workers are unregistered
    report_event "complete"
  end

  #
  def shutdown
    report_event "shutting down"
  end


  def report_event event
    redis.zadd("arbiter:events", "#{Time.now.utc.to_f}:#{event}")
  end

end
