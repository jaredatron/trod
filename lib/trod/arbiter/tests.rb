class Trod::Arbiter::Tests

  include Enumerable

  attr_reader :arbiter, :names

  def initialize arbiter
    @arbiter, @names = arbiter, []
  end

  def detect!
    detect_specs!
  end

  def each
    names.each{|name|
      yield name # TODO Test.new
    }
  end

  private

  # scans the workspace for spec files and uses their relative path as their name
  def detect_specs!
    root = arbiter.project.root
    Dir[root.join('spec/**/*_spec.rb')].flatten. map{ |spec|
      name = Pathname.new(spec).relative_path_from(root).to_s
      names << "spec:#{name}"
    }
    names.uniq!
  end

  # executes a cucumber command to list all scenarios by name
  def detect_scenarios!
    test_run.workspace.execute %W[
      cucumber --quiet --dry-run --no-profile
      --require #{Hobson.lib.join('hobson/formatters/scenarios.rb')}
      --format Hobson::Formatters::Scenarios --out hobson_scenarios_list
    ]*' '
    scenarios = test_run.workspace.root.join('hobson_scenarios_list').read.split("\n")
    # some crazy duplicate detection code i copied from the interwebz
    dups = scenarios.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
    raise "Hobson cannot handle duplicate scenario names\nPlease correct these: #{dups.inspect}" if dups.present?
    scenarios.each{|name| add "scenario:#{name}"}
  end


end
