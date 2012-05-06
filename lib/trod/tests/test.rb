class Trod::Tests::Test

  attr_reader :redis, :index, :type, :name

  def initialize redis, index, type, name
    @redis, @index, @type, @name = redis, index, type, name
  end

  def inspect
    %{#<#{self.class} ##{index} #{type}:#{name}>}
  end
  alias_method :to_s, :index

end
