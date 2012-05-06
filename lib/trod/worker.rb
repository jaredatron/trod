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
    # start_test_server
    load_the_test_environment
    process_test_queue
    unregister
    shutdown
  rescue Object => e
    logger.error "#{e}\n#{e.backtrace*"\n"}"
    raise
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

  def load_the_test_environment
    # define in subclass
  end


  def process_test_queue
    report_event "processing #{test_type} queue"

    while test = queue.pop
      if !test.need_to_be_run?
        report_event "skipping test: #{test.id}"
        next
      end
      report_event "running test: #{test.id}"
      test.trying!

      result = run_test(test)

      report_event "done running test: #{test.id} #{result ? 'PASS' : 'FAIL'}"
      result ? test.pass! : test.fail!
      logger.info "here"
    end

    report_event "finished processing #{test_type} queue"
  end

  def run_test
    # define in subclass
  end

  def register
    logger.debug "REGISTERING: #{id}"
    redis.sadd(:workers, id)
  end

  def unregister
    logger.debug "UNREGISTERING: #{id}"
    redis.srem(:workers, id)
  end

  def shutdown
    report_event "shutting down"
  end

  def queue
    @queue ||= tests.queues[test_type]
  end

end
