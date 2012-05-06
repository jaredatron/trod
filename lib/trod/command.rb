class Trod::Command

  def initialize args=ARGV.clone
    @args, @options = args, {}
    parse_args!
    p self
  end
  attr_accessor :options

  private

  def parse_args!
    options = self.options
    OptionParser.new do |opts|
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
      end
    end.parse!
  end

end
