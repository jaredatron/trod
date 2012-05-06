class Trod::Project

  def root
    @root ||= Pathname File.expand_path('.')
  end

  def rvm?
    root.join('.rvmrc').exist?
  end

  def rvm_source_file
    File.expand_path('~/.rvm/scripts/rvm')
  end

  def bundler?
    root.join('Gemfile').exist?
  end

  def prepare
    execute 'gem install bundler && bundle check || bundle install' if bundler?
    root.join('log').mkpath
  end

  ExecutionError = Class.new(StandardError)

  def execute command
    command = "cd #{root.to_s.inspect} && #{command}"
    command = "source #{rvm_source_file.inspect} && rvm rvmrc trust #{root.to_s.inspect} > /dev/null && #{command}" if rvm?
    command = "bash -lc #{command.inspect}"

    output = nil
    errors = nil
    status = POpen4::popen4(command){|stdout, stderr, stdin|
      output = stdout.read
      errors = stderr.read
    }

    raise ExecutionError, "COMMAND FAILED TO START\n#{command}" if status.nil?
    raise ExecutionError, "COMMAND EXITED WITH CODE #{$?.exitstatus}\n#{command}\n\n#{errors}" unless $?.success?

    return output
  end

end
