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
    arbiter.project.execute %W[
      cucumber --quiet --dry-run --no-profile
      --require #{Trod::LIB.join('trod/formatters/scenarios.rb')}
      --format Trod::Formatters::Scenarios --out .trod-scenarios
    ]*' '
    scenarios = arbiter.project.root.join('.trod-scenarios').read.split("\n")
    # some crazy duplicate detection code i copied from the interwebz
    dups = scenarios.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
    raise "Trod cannot handle duplicate scenario names\nPlease correct these: #{dups.inspect}" if dups.present?
    scenarios.each{|name| names << "scenario:#{name}"}
  end


end
