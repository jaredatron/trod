class Trod::Workers::SpecWorker < Trod::Worker

  def load_the_test_environment
    report_event "loading the test environment"
    ENV["RAILS_ENV"] = 'test'
    require File.expand_path('spec/spec_helper')
    require 'rspec'
    require 'rspec/core'
    report_event "done loading the test environment"
  end


  def run_test test
    args = [test.name]
    args.unshift *%w{--format d}
    args.unshift *%w{--out log/rspec.log}

    log_dir = Pathname(File.expand_path('log'))
    log_dir.mkdir unless log_dir.exist?
    rspec_log_path = log_dir.join('rspec.log')

    pid = fork{
      ARGV.replace(args)
      STDOUT.reopen(rspec_log_path)
      STDERR.reopen(rspec_log_path)
      RSpec::Core::Runner.autorun
      # TODO find test and check its name and result
    }

    Process.wait(pid)
    return $?.success?
  end


end
