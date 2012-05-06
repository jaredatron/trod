require "trod/version"
require 'pathname'

module Trod
  autoload :Command, 'trod/command'
  autoload :Project, 'trod/project'
  autoload :Tests,   'trod/tests'
  autoload :Client,  'trod/client'
  autoload :Arbiter, 'trod/arbiter'
  autoload :Worker,  'trod/worker'

  LIB = Pathname File.expand_path('..', __FILE__)

end
