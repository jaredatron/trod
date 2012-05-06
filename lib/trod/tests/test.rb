class Trod::Tests::Test

  MAX_TRIES = 3
  POSSIBLE_RESULTS = %w{pass fail pending hung}

  class << self
    def register tests, type, name
      test = new(tests, "#{type}:#{name}")
      test.result = nil
      test.enqueue!
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
    queue.push(self) if need_to_be_run?
  end

  def pass!
    self.result = 'pass'
  end

  def fail!
    need_to_be_run? ? enqueue! : self.result = 'fail'
  end

  def pending!
    need_to_be_run? ? enqueue! : self.result = 'pending'
  end

  def hung!
    redis.hincrby(:test_hangs, self, 1)
    need_to_be_run? ? enqueue! : self.result = 'hung'
  end

  # State

  def status

  end

  POSSIBLE_RESULTS.each{|state|
    define_method(:"#{state}?"){ # def pass?
      result == state            # def fail?
    }                            # def pending?
  }                              # def hung?

  def need_to_be_run?
    !pass? && tries < MAX_TRIES
  end

  def to_json *args
    {
      :name   => name,
      :type   => type,
      :result => result,
      :tries  => tries,
      :hangs  => hangs,
    }.to_json
  end

  private

  def redis
    tests.redis
  end

end
