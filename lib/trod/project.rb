class Trod::Project

  def root
    @root ||= Pathname File.expand_path('.')
  end

  def execute command
    command = "cd #{root.to_s.inspect} && #{command}"
    output = nil
    errors = nil
    status = POpen4::popen4(command){|stdout, stderr, stdin|
      output = stdout.read
      errors = stderr.read
    }
    return output
  end

end
