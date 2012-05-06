require 'ruby-debug'

require "trod/version"
require 'pathname'

module Trod
  autoload :Cli,           'trod/cli'
  autoload :Server,        'trod/server'
  autoload :Project,       'trod/project'
  autoload :Tests,         'trod/tests'
  autoload :Arbiter,       'trod/arbiter'
  autoload :Worker,        'trod/worker'
  autoload :Workers,       'trod/workers'

  LIB = Pathname File.expand_path('..', __FILE__)
  PWD = Pathname File.expand_path('.')

end
