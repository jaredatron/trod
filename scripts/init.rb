#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'pp'

workspace_path = File.expand_path('workspace')
config_path = File.expand_path('config.json') # this will be cloud tags later
config = JSON.parse File.read config_path
project, sha = config.values_at('project', 'sha')

Pathname(workspace_path).rmtree if File.exist? workspace_path

puts "WORKSPACE PATH:\n#{workspace_path}"
puts "CONFIG:"
pp config
puts

config.each_pair{|key, value| ENV["TROD_#{key.upcase}"] = value.to_s }

command = <<-SH
  git clone --verbose -- #{project.inspect} #{workspace_path.inspect} &&
  cd #{workspace_path.inspect} &&
  git checkout  #{sha.inspect} &&
  bundle check || bundle install &&
  bundle exec trod-server
SH

puts command

# system(command)

require 'ruby-debug'
debugger;1

