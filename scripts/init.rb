#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'pp'

WORKSPACE_PATH = File.expand_path('workspace')
CONFIG_PATH = File.expand_path('config.json') # this will be cloud tags later
CONFIG = JSON.parse File.read CONFIG_PATH

Pathname(WORKSPACE_PATH).rmtree if File.exist? WORKSPACE_PATH

puts "WORKSPACE PATH:\n#{WORKSPACE_PATH}"
puts "CONFIG:"
pp CONFIG
puts

CONFIG["project"] or raise "project missing"
CONFIG["sha"]     or raise "sha missing"

command = <<-SH
  git clone --verbose -- #{CONFIG["project"].inspect} #{WORKSPACE_PATH.inspect} &&
  cd #{WORKSPACE_PATH.inspect} &&
  git checkout  #{CONFIG["sha"].inspect} &&
  bundle check || bundle install &&
  bundle exec trod worker
SH

puts command

system(command)
