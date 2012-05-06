require "ostruct"

class Trod::Command

  class << self
    attr_accessor :option_parser_block
    def options &block
      raise ArgumentError unless block_given?
      @option_parser_block = block
    end
  end

  def initialize args=ARGV.clone
    @args, @options = args, OpenStruct.new
    parse_args!
    p self
    run!
  end
  attr_accessor :options

  def inspect
    %{#<#{self.class} #{options.send(:table).inspect}>}
  end

  private

  def default_project
    `git config --get remote.origin.url`.chomp
  end

  def default_sha
    `git rev-parse HEAD`.chomp
  end

  def parse_args!
    worker = self
    OptionParser.new do |opts|

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        worker.options.verbose = v
      end

      opts.on("-p", "--project (#{default_project})") do |project|
        worker.options.project = project
      end

      opts.on("-s", "--sha (#{default_sha})") do |sha|
        worker.options.sha = sha
      end

      if block = worker.class.option_parser_block
        block.call(opts, worker)
      end

    end.parse!
  end

end
