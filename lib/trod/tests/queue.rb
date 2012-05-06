class Trod::Tests::Queue

  attr_reader :redis, :test_type, :key

  def initialize redis, test_type
    @redis, @test_type = redis, test_type
    @key = "#{test_type}s_needing_to_be_run"
  end

  def push test
    test.type == test_type or raise "wrong test type for this queue"
    redis.rpush(key, test)
  end

  def pop
    Trod::Tests::Test.new(redis, redis.rpop(key))
  end

  def to_a
    redis.lrange(key, 0, 99999999)
  end

end
