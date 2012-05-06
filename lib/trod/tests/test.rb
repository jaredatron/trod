class Trod::Tests::Test

  MAX_TRIES = 3
  POSSIBLE_RESULTS = %w{pass fail pending hung}

  class << self
    def register tests, type, name
      test = new(tests, "#{type}:#{name}")
      test.result = nil
      test
    end

    alias_method :find, :new
  end

  attr_reader :tests, :type, :name

  def initialize tests, id
    @tests = tests
    @type, @name = id.scan(/^(.+?):(.+)$/).first
  end

  def id
    "#{type}:#{name}"
  end
  alias_method :to_s, :id

  def inspect
    %{#<#{self.class} #{id}>}
  end

  def queue
    tests.queues[type]
  end

  def result
    redis.hget(:test_results, self)
  end

  def result= result
    redis.hset(:test_results, self, result)
  end

  def tries
    redis.hget(:test_tries, self).to_i
  end

  def trying!
    redis.hincrby(:test_tries, self, 1)
    self
  end

  def hangs
    redis.hget(:test_hangs, self)
  end

  # Actions

  def enqueue!
    queue.push(self) if should_be_enqueued?
  end

  def pass!
    self.result = 'pass'
  end

  def fail!
    has_more_tries? ? enqueue! : self.result = 'fail'
  end

  def pending!
    has_more_tries? ? enqueue! : self.result = 'pending'
  end

  def hung!
    redis.hincrby(:test_hangs, self, 1)
    has_more_tries? ? enqueue! : self.result = 'hung'
  end

  # State

  def status

  end

  POSSIBLE_RESULTS.each{|state|
    define_method(:"#{state}?"){ # def pass?
      result == state            # def fail?
    }                            # def pending?
  }                              # def hung?

  def should_be_enqueued?
    !pass? && tries < MAX_TRIES
  end

  private

  def redis
    tests.redis
  end

end
