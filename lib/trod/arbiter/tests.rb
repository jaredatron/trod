class Trod::Arbiter::Tests

  include Enumerable

  attr_reader :arbiter, :tests

  def initialize arbiter
    @arbiter, @tests = arbiter, []
  end

  def detect!
  end


  private

  # scans the workspace for spec files and uses their relative path as their name
  def detect_specs!
    Dir[arbiter.project.root.join('spec/**/*_spec.rb')].flatten. map{ |spec|
      name = Pathname.new(spec).relative_path_from(test_run.workspace.root).to_s
      add("spec:#{name}")
    }
  end

end
