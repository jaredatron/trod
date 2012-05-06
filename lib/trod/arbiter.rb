class Trod::Arbiter < Trod::Command

  def run!
    start_redis_server
    report_status
    detect_tests
    start_workers
    report_status_until_complete
    shutdown

    require "ruby-debug"
    debugger;1
  end

  private

  attr_reader :redis

  #
  def start_redis_server
    require 'simple-redis-server'
    @redis_server = Redis::Server.new
    @redis_server.start
    sleep 0.2
    @redis = @redis_server.connect
    report_event "redis server started"
  end

  #
  def report_status
    # TODO place a json file on S3
  end

  #
  def detect_tests
    report_event "detecting tests"
    tests.detect!
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
    redis.hset("arbiter:events", Time.now.utc.to_f, event)
  end

  # returns the events that arbiter has logged so far
  def logged_events
    redis.hgetall("arbiter:events").to_a.map{|t,e| [Time.at(t.to_f),e] }.sort_by(&:first)
  end

  def tests
    @tests ||= Trod::Tests.new(self)
  end

end
