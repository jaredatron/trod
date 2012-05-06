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


    require "ruby-debug"
    debugger;1

    prepare_project
    start_test_server
    process_test_queue
    unregister
    shutdown
  end

  def id
    @id ||= "worker:#{hostname}:#{Process.pid}"
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
    # TODO shutdown
  end

end
