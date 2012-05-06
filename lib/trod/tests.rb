class Trod::Tests

  autoload :Test, 'trod/tests/test'

  include Enumerable

  attr_reader :project, :redis

  def initialize project, redis
    @project, @redis = project, redis
  end

  def detect!
    redis.pipelined{
      specs     = detect_specs!.map{|name| "spec:#{name}"}
      scenarios = detect_scenarios!.map{|name| "scenario:#{name}"}

      specs.each{|id| redis.rpush(:specs_needing_to_be_run, id) }
      scenarios.each{|id| redis.rpush(:scenarios_needing_to_be_run, id) }

      tests = specs + scenarios

      tests.each{|id|
        redis.hset(:test_results, id, nil)
        redis.hset(:test_tries, id, 0)
      }

      redis.set :number_of_tests, @number_of_tests = tests.size
    }
    @tests = nil
  end

  def [] id
    Test.new(redis, id)
  end

  def each
    tests.each{|name|
      yield name # TODO Test.new
    }
  end

  def number_of_tests
    @number_of_tests ||= redis.get(:number_of_tests).to_i
  end
  alias_method :length, :number_of_tests
  alias_method :size, :number_of_tests

  def tests
    @tests ||= redis.hkeys(:test_results).map{|id| self[id] }
  end

  def pop_test_waiting_to_be_run worker
    id = redis.rpop("#{worker.test_type}s_needing_to_be_run")
    self[id]
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
    project.execute %W[
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
