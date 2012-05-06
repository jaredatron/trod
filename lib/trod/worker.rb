class Trod::Worker < Trod::Command

  options{|opts, worker|

    opts.on("-t", "--type (rspec|cucumber)") do |type|
      worker.options.type = type
    end

    opts.on("-r", "--redis (redis://127.0.0.1:6379/0)") do |redis|
      worker.options.redis = redis
    end

  }

  def run!
    puts "becoming a worker"

    p redis
  end

  private

  def redis
    @redis ||= Redis.connect url: options.redis
  end

end
