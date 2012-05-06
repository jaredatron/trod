require 'redis'

class Trod::Worker < Trod::Server

  attr_reader :test_type, :redis

  def initialize
    super
    @test_type = ENV['TROD_TEST_TYPE']
    @redis     = Redis.connect :url => ENV['TROD_REDIS']
    logger.info "worker started #{self.inspect}"
  end

  def run!
    register
    prepare_project
    start_test_server
    process_test_queue
    unregister
    shutdown
  end

  def id
    @id ||= "worker:#{test_type}:#{hostname}:#{Process.pid}"
  end

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
    report_event "processing #{test_type} queue"
    # TODO loop poping tests from redis

    while test = queue.pop
      if !test.need_to_be_run?
        report_event "skipping test: #{test.id}"
        next
      end
      report_event "running test: #{test.id}"
      test.trying!
      # require "ruby-debug"
      # debugger;1
      test.pass!
    end
    report_event "finished processing #{test_type} queue"
  end

  def test_queue_name
    @test_queue_name ||= "tests:#{test_type}"
  end


  def register
    redis.sadd(:workers, id)
  end

  def unregister
    redis.srem(:workers, id)
  end

  def shutdown
    report_event "shutting down"
    exit
  end

  def queue
    @queue ||= tests.queues[test_type]
  end

end
