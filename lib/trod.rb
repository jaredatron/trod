require "trod/version"
require 'optparse'

module Trod
  autoload :Command, 'trod/command'
  autoload :Client,  'trod/client'
  autoload :Arbiter, 'trod/arbiter'
  autoload :Worker,  'trod/worker'
end
