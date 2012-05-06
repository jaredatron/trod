require 'logger'

class Trod::Server

  def self.start!
    case ENV['TROD_ROLE']
      when 'arbiter'; Trod::Arbiter.new.run!
      when 'worker';  Trod::Worker.new.run!
      else; raise "unknown role"
    end
  end

  attr_reader :project_workspace_path, :project_origin, :project_sha

  def initialize
    @project_workspace_path = ENV['TROD_PROJECT_WORKSPACE_PATH']
    @project_origin         = ENV['TROD_PROJECT_ORIGIN']
    @project_sha            = ENV['TROD_PROJECT_SHA']
  end

  def project
    @project ||= Trod::Project.new(project_workspace_path)
  end

  def logger
    Logger.new
  end

end

