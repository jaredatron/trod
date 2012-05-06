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
    report_event "loading the test environment"
    ENV["RAILS_ENV"] = 'test'
    require File.expand_path('spec/spec_helper')
    require 'rspec'
    require 'rspec/core'
    report_event "done loading the test environment"
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

      case test.type
      when 'spec'; result = run_spec(test.name)
      when 'scenario'; result = true
      end

      report_event "done running test: #{test.id} #{result ? 'PASS' : 'FAIL'}"
      result ? test.pass! : test.fail!
      logger.info "here"
    end

    report_event "finished processing #{test_type} queue"
  end

  def test_queue_name
    @test_queue_name ||= "tests:#{test_type}"
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


  def run_spec spec
    args = [spec]
    args.unshift *%w{--format d}
    args.unshift *%w{--out log/rspec.log}

    log_dir = Pathname(File.expand_path('log'))
    log_dir.mkdir unless log_dir.exist?
    rspec_log_path = log_dir.join('rspec.log')

    pid = fork{
      ARGV.replace(args)
      STDOUT.reopen(rspec_log_path)
      STDERR.reopen(rspec_log_path)
      RSpec::Core::Runner.autorun
      # TODO find test and check its name and result
    }

    Process.wait(pid)
    return $?.success?
  end


end
