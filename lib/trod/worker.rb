class Trod::Worker < Trod::Command

  options{|opts, worker|

    opts.on("-t", "--type (rspec|cucumber)") do |type|
      worker.options.type = type
    end

    opts.on("-r", "--redis") do |redis|
      worker.options.redis = redis
    end

  }

  def run!
    puts "becoming a worker"
  end

end
