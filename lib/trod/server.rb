require 'logger'

class Trod::Server

  def self.start!
    case ENV['TROD_ROLE']
      when 'arbiter'; Trod::Arbiter.new.run!
      when 'worker';
        case ENV['TROD_TEST_TYPE']
        when 'spec';     Trod::Workers::SpecWorker.new.run!
        when 'scenario'; Trod::Workers::ScenarioWorker.new.run!
        end

      else; raise "unknown role"
    end
  end

  attr_reader \
    :workspace_path,
    :project_workspace_path,
    :project_origin,
    :project_sha

  def initialize
    @workspace_path         = Pathname ENV['TROD_WORKSPACE_PATH']
    @project_workspace_path = Pathname ENV['TROD_PROJECT_WORKSPACE_PATH']
    @project_origin         = ENV['TROD_PROJECT_ORIGIN']
    @project_sha            = ENV['TROD_PROJECT_SHA']
  end

  def project
    @project ||= Trod::Project.new(project_workspace_path)
  end

  def tests
    @tests ||= Trod::Tests.new(project, redis)
  end

  def logger
    @logger or begin
      log_dir = workspace_path.join('log')
      log_dir.mkdir unless log_dir.exist?
      @logger = Logger.new(log_dir.join('trod.log'))
      logger.formatter = proc{ |severity, datetime, progname, msg|
        padded_id = "#{id}#{' '*50}"[0..50]
        msg.split("\n").map{|line| "[#{padded_id}][#{datetime}]: #{line}" }.join("\n")+"\n"
      }
    end
    @logger
  end

  def report_event event
    logger.info event
    redis.hset("#{id}:events", Time.now.utc.to_f, event)
  end

  # returns the events that arbiter has logged so far
  def reported_events
    redis.hgetall("#{id}:events").to_a.map{|t,e| [Time.at(t.to_f),e] }.sort_by(&:first)
  end

  def inspect
    %{#<#{self.class} #{id}>}
  end
  alias_method :to_s, :inspect

end

