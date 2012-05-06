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
    puts "#{self.class} #{options.inspect}"
    run!
  end
  attr_accessor :options

  private

  def parse_args!
    worker = self
    OptionParser.new do |opts|
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        worker.options.verbose = v
      end

      if block = worker.class.option_parser_block
        block.call(opts, worker)
      end

    end.parse!
  end

end
