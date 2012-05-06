class Trod::Worker < Trod::ServerCommand

  options{|opts, worker|

    opts.on("-t", "--type (rspec|cucumber)") do |type|
      worker.options.type = type.to_sym
    end

    opts.on("-r", "--redis (redis://127.0.0.1:6379/0)") do |redis|
      worker.options.redis = redis
    end

  }

  attr_reader :test_type, :redis

  def initialize
    super
    @test_type = ENV['TROD_TEST_TYPE']
    @redis     = Redis.connect :url => ENV['TROD_REDIS']
  end


  def run!

    # register
    # prepare_project
    # start_test_server
    # process_test_queue
    # unregister
    # shutdown

    require "ruby-debug"
    debugger;1
  end

  def to_s
    @to_s ||= "worker:#{hostname}:#{Process.pid}"
  end
  alias_method :id, :to_s

  def hostname
    @hostname ||= `hostname`.chomp
  end

  private

  def prepare_project
    report_event "preparing project"
    # TODO run setup hook
  end

  def start_test_server
    report_event "starting test server"
    # TODO start cucumber/rspec test server

  end

  def process_test_queue
    report_event "processing #{options.type} queue"
    # TODO loop poping tests from redis

  end

  def test_queue_name
    @test_queue_name ||= "tests:#{options.type}"
  end

  def report_event event
    redis.rpush("worker:#{id}:events", "#{Time.now.utc.to_f}:#{event}")
  end

  def register
    redis.sadd(:workers, self)
  end

  def unregister
    redis.srem(:workers, self)
  end

  def shutdown
    report_event "shutting down"
    # TODO shutdown
  end

end
