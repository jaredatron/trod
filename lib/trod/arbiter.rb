require 'json'

class Trod::Arbiter < Trod::Server

  attr_reader :number_of_rspec_workers, :number_of_cucumber_workers, :redis_server

  def initialize
    super
    @number_of_rspec_workers    = ENV['TROD_NUMBER_OF_RSPEC_WORKERS'].to_i
    @number_of_cucumber_workers = ENV['TROD_NUMBER_OF_CUCUMBER_WORKERS'].to_i
    logger.info "arbitor started #{self.inspect}"
  end

  def run!
    start_redis_server
    report_status
    detect_tests
    start_workers
    report_status_until_complete
    shutdown

    debugger;1
  end

  def id
    "arbitor"
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

    workers = \
      (1..number_of_rspec_workers).to_a.map{:spec} +
      (1..number_of_cucumber_workers).to_a.map{:scenario}

    puts "\n\n MANUAL FOR NOW \n\n"

    workers.each{|test_type|
      puts "START A WORKER WITH THIS CONFIG:"
      puts worker_config.merge(:test_type => test_type).to_json
      puts
    }

    puts "\n\n MANUAL FOR NOW \n\n"

    debugger;1

    # THIS IS A TOTAL HACK FOR TESTING
    #ChildProcess.new('cd /Volumes/Chest/deadlyicon/tmp/trod_worker1 && ./init.rb').start
    #ChildProcess.new('cd /Volumes/Chest/deadlyicon/tmp/trod_worker2 && ./init.rb').start

    report_event "finished starting workers"
  end

  #
  def report_status_until_complete
    # TODO loop reporting state to S3 until all queues are empty & all workers are unregistered
    require "ruby-debug"
    debugger;1
  end

  #
  def shutdown
    report_event "shutting down"
  end

  def workers
    redis.smembers(:workers).map{|id|
      worker = Trod::Worker.new
      worker.instance_variable_set(:@id, id)
      worker.instance_variable_set(:@redis, redis)
      worker
    }
  end

  def worker_config
    {
      :project_origin => project_origin,
      :project_sha => project_sha,
      :role => :worker,
      :redis => redis.id,
    }
  end

end
