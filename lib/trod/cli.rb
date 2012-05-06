require 'trod'
require 'ostruct'

class Trod::Cli

  def self.start!
    new
  end

  attr_reader :options

  def initialize
    @options = OpenStruct.new
    parse_options!
    options.project_origin ||= `git config --get remote.origin.url`.chomp
    options.project_sha    ||= `git rev-parse HEAD`.chomp

    p options

    require "ruby-debug"
    debugger;1
  end

  def parse_options!
    options = @options
    OptionParser.new do |opts|

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      opts.on("-p", "--project (project origin)") do |project|
        options.project_origin = project
      end

      opts.on("-s", "--sha (project sha)") do |sha|
        options.project_sha = sha
      end

    end.parse!
  end

end
