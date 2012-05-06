class Trod::Tests

  autoload :Tests, 'trod/tests/test'

  include Enumerable

  attr_reader :project

  def initialize project, redis
    @project, @redis = project, redis
  end

  # def add type, name
  #   tests << Test.new(redis, type, name)
  # end

  def detect!
    @tests = []
    redis.pipelined{
      detect_specs!.each{|name| redis.rpush(:tests, "specs:#{name}") }
      detect_scenarios!.each{|name| redis.rpush(:tests, "scenario:#{name}") }
      @number_of_tests = detect_specs!.size + detect_scenarios!
      redis.set :number_of_tests, @number_of_tests
    }
  end

  def each
    tests.each{|name|
      yield name # TODO Test.new
    }
  end

  def number_of_tests
    @number_of_tests ||= redis.get(:number_of_tests).to_i
  end

  def tests
    @tests ||= redis.lrange(:tests, 0, 999999999).map{|test|
      Test.new(redis, *test.scan(/^(.+?):(.+)$/).first)
    }
  end

  private

  # scans the workspace for spec files and uses their relative path as their name
  def detect_specs!
    return Dir[project.root.join('spec/**/*_spec.rb')].flatten.map{ |spec|
      Pathname.new(spec).relative_path_from(project.root).to_s
    }
  end

  # executes a cucumber command to list all scenarios by name
  def detect_scenarios!
    arbiter.project.execute %W[
      cucumber --quiet --dry-run --no-profile
      --require #{Trod::LIB.join('trod/formatters/scenarios.rb')}
      --format Trod::Formatters::Scenarios --out .trod-scenarios
    ]*' '
    scenarios = project.root.join('.trod-scenarios').read.split("\n")
    # some crazy duplicate detection code i copied from the interwebz
    dups = scenarios.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
    raise "Trod cannot handle duplicate scenario names\nPlease correct these: #{dups.inspect}" unless dups.empty?
    return scenarios
  end

  def uniq!
    # TODO handle duplicates
  end

end
