class Trod::Tests::Test

  attr_reader :redis, :type, :name

  def initialize redis, id
    @redis = redis
    @type, @name = id.scan(/^(.+?):(.+)$/).first
  end

  def inspect
    %{#<#{self.class} ##{index} #{type}:#{name}>}
  end
  alias_method :to_s, :inspect

  def index

  end


end
