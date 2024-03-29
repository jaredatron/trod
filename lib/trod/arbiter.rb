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
  rescue Object => e
    puts "#{e}\n#{e.backtrace*"\n"}"
    logger.error "#{e}\n#{e.backtrace*"\n"}"
    raise
  ensure
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
    report_event "reporting status"
    # TODO place a json file on S3
    status = {
      :workspace_path => workspace_path,
      :project_workspace_path => project_workspace_path,
      :project_origin => project_origin,
      :project_sha => project_sha,
      :number_of_rspec_workers => number_of_rspec_workers,
      :number_of_cucumber_workers => number_of_cucumber_workers,
      :tests => tests,
      :tests_done => tests.find_all{|t| !t.need_to_be_run? }.size,
      :tests_not_done => tests.find_all{|t| t.need_to_be_run? }.size,
    }

    workspace_path.join('temp_status_report.json').open('w'){|f|
      f.write status.to_json
    }
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

    workers.each_with_index{|test_type, index|
      config_json = worker_config.merge(:test_type => test_type).to_json
      # puts config_json

      # TODO make two classes, one for a local worker one for a cloud worker
      start_local_worker_for_development! index, config_json
    }

    report_event "finished starting workers"
  end

  #
  def report_status_until_complete
    report_event "waiting for workers to finish"
    # TODO loop reporting state to S3 until all queues are empty & all workers are unregistered
    while tests.any?(&:need_to_be_run?) || !workers.empty?
      report_status
      # debugger;1
      sleep 1
    end
    report_event "all done"
  end

  #
  def shutdown
    report_event "shutting down"
  end

  def workers
    redis.smembers(:workers)
    # .map{|id|
      # worker = Trod::Worker.new
      # worker.instance_variable_set(:@id, id)
      # worker.instance_variable_set(:@redis, redis)
      # worker
    # }
  end

  def worker_config
    {
      :project_origin => project_origin,
      :project_sha => project_sha,
      :role => :worker,
      :redis => redis.id,
    }
  end

  TMP_PATH = Pathname File.expand_path('~/tmp/')
  INIT_SCRIPT_PATH = Trod::LIB + '../scripts/init.rb'

  def start_local_worker_for_development! index, config_json
    dir = TMP_PATH + "trod_worker#{index}"
    dir.mkdir unless dir.exist?
    dir.join('config.json').open('w'){|f| f.write config_json }
    unless dir.join('init.rb').exist?
      `cd #{dir.to_s.inspect} && ln -s #{INIT_SCRIPT_PATH}`
    end
    cmd  = "cd #{dir.to_s.inspect} && ./init.rb"
    puts "\n\nSTARTING: #{cmd}"
    cp = ChildProcess.new(cmd).start
    puts "PID: #{cp.pid}"
  end

end
