class Trod::Tests::Test

  attr_reader :redis, :type, :name

  def initialize redis, id
    @redis = redis
    @type, @name = id.scan(/^(.+?):(.+)$/).first
  end

  def id
    "#{type}:#{name}"
  end
  alias_method :to_s, :id

  def inspect
    %{#<#{self.class} #{id}>}
  end

end
