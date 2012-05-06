#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'pp'

workspace_path = File.expand_path('workspace')
config_path = File.expand_path('config.json') # this will be cloud tags later
config = JSON.parse File.read config_path
config[:project_workspace_path] = workspace_path

puts "WORKSPACE PATH:\n#{workspace_path}"
puts "CONFIG:"
pp config
puts

project_origin, project_sha = config.values_at('project_origin', 'project_sha')

project_origin or raise "missing project origin"
project_sha    or raise "missing project sha"

config.each_pair{|key, value| ENV["TROD_#{key.upcase}"] = value.to_s }

command = <<-SH
  git clone --verbose -- #{project_origin.inspect} #{workspace_path.inspect} &&
  cd #{workspace_path.inspect} &&
  git checkout #{project_sha.inspect} &&
  bundle check || bundle install &&
  bundle exec trod-server
SH

puts command

Pathname(workspace_path).rmtree if File.exist? workspace_path

system(command)

# require 'ruby-debug'
# debugger;1

