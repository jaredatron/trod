class Trod::Worker < Trod::Command

  options{|opts, worker|

    opts.on("-t", "--type (rspec|cucumber)") do |type|
      worker.options.type = type.to_sym
    end

    opts.on("-r", "--redis (redis://127.0.0.1:6379/0)") do |redis|
      worker.options.redis = redis
    end

  }

  def run!
    # case options.type
    # when :rspec;    Trod::Workers::Rspec.new(options)
    # when :cucumber; Trod::Workers::Cucumber.new(options)
    # else; raise "unknown worker type #{options.type}"
    # end

    register
    prepare_project
    start_test_server
    process_test_queue
    unregister
    shutdown
  end

  def to_s
    @to_s ||= "#{hostname}:#{Process.pid}"
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
    redis.zadd("worker:#{id}:events", "#{Time.now.utc.to_f}:#{event}")
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

  def redis
    @redis ||= Redis.connect :url => options.redis
  end

end
