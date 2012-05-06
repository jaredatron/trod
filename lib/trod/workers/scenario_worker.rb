class Trod::Workers::ScenarioWorker < Trod::Worker

  def load_the_test_environment
    ENV["RAILS_ENV"] ||= 'test'
    require 'cucumber'
    require File.expand_path('features/support/env')
  end


  def run_test test
    args = ['--name', %{^#{test.name}$}]
    # args.unshift *%w{--out log/cucumber.log}

    log_dir = Pathname(File.expand_path('log'))
    log_dir.mkdir unless log_dir.exist?
    cucumber_log_path = log_dir.join('cucumber.log')

    pid = fork{
      STDOUT.reopen(cucumber_log_path)
      STDERR.reopen(cucumber_log_path)

      runtime = ::Cucumber::Runtime.new
      main = ::Cucumber::Cli::Main.new(args)
      main.execute!(runtime)
      if runtime.results.scenarios.size == 0
        warn "unable to find scenario"
        exit 1
      end
      if runtime.results.scenarios.size > 1
        warn "more then expected was run"
        exit 1
      end
      unless runtime.results.scenarios.first.name == scenario
        warn "wrong scenario was run"
        exit 1
      end
      exit(1) unless runtime.results.scenarios.first.passed?
    }

    Process.wait(pid)
    return $?.success?
  end


end
