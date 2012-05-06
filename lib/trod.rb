require "trod/version"
require 'pathname'

module Trod
  autoload :Server,        'trod/server'
  autoload :Command,       'trod/command'
  autoload :ServerCommand, 'trod/server_command'
  autoload :Project,       'trod/project'
  autoload :Tests,         'trod/tests'
  autoload :Client,        'trod/client'
  autoload :Arbiter,       'trod/arbiter'
  autoload :Worker,        'trod/worker'

  LIB = Pathname File.expand_path('..', __FILE__)
  PWD = Pathname File.expand_path('.')

end
