class Trod::Server

  def self.start!
    case ENV['TROD_ROLE']
      when 'arbiter'; Trod::Arbiter.new.run!
      when 'worker';  Trod::Worker.new.run!
      else; raise "unknown role"
    end
  end

  attr_reader :project_origin, :project_sha

  def initialize
    @project = ENV['TROD_PROJECT_ORIGIN']
    @sha     = ENV['TROD_PROJECT_SHA']
  end

end

