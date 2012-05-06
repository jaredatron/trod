require "trod/version"
require 'optparse'
require 'redis'
require 'pathname'
require 'popen4'

module Trod
  autoload :Command, 'trod/command'
  autoload :Project, 'trod/project'
  autoload :Client,  'trod/client'
  autoload :Arbiter, 'trod/arbiter'
  autoload :Worker,  'trod/worker'
end
