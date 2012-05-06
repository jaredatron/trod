require 'optparse'

class Trod::Cli

  def initialize args=ARGV.clone


  end

  def options
    @options ||= begin
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end

      end.parse!
      options
    end
  end

end
