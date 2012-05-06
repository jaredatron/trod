#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'pp'

workspace_path = File.expand_path('workspace')
config_path = File.expand_path('config.json') # this will be cloud tags later
config = JSON.parse File.read config_path
config[:project_workspace_path] = workspace_path
project_origin, project_sha = config.values_at('project', 'project_sha')


puts "WORKSPACE PATH:\n#{workspace_path}"
puts "CONFIG:"
pp config
puts

config.each_pair{|key, value| ENV["TROD_#{key.upcase}"] = value.to_s }

command = <<-SH
  git clone --verbose -- "${TROD_PROJECT_ORIGIN}" "${TROD_PROJECT_WORKSPACE_PATH}" &&
  cd "${TROD_PROJECT_WORKSPACE_PATH}" &&
  git checkout "${TROD_PROJECT_SHA}" &&
  bundle check || bundle install &&
  bundle exec trod-server
SH

puts command

Pathname(workspace_path).rmtree if File.exist? workspace_path

system(command)

# require 'ruby-debug'
# debugger;1

