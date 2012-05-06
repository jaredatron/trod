require 'logger'

class Trod::Server

  def self.start!
    case ENV['TROD_ROLE']
      when 'arbiter'; Trod::Arbiter.new.run!
      when 'worker';  Trod::Worker.new.run!
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

  def logger
    @logger ||= begin
      log_dir = workspace_path.join('log')
      log_dir.mkdir
      Logger.new(log_dir.join('trod.log'))
    end
  end

end

