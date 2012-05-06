require 'json'

class Trod::Arbiter < Trod::Command

  options{|opts, worker|

    opts.on("-w", "--workers ({rspec:5,cucumber:15})") do |workers|
      worker.options.workers = JSON.parse(workers)
    end

  }

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
    report_event "started detecting tests"
    tests.detect!
    report_event "completed detecting tests"
    report_status
  end

  #
  def start_workers
    report_event "started starting workers"

    # THIS IS A TOTAL HACK FOR TESTING
    ChildProcess.new('cd /Volumes/Chest/deadlyicon/tmp/trod_worker1 && ./init.rb').start
    ChildProcess.new('cd /Volumes/Chest/deadlyicon/tmp/trod_worker2 && ./init.rb').start

    report_event "finished starting workers"
  end

  #
  def report_status_until_complete
    # TODO loop reporting state to S3 until all queues are empty & all workers are unregistered
    report_event "complete"

    require "ruby-debug"
    debugger;1
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
    @tests ||= Trod::Tests.new(project, redis)
  end

  def workers
    @workers ||= []
  end

end
