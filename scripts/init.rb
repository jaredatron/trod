#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'pp'

workspace_path = File.expand_path('workspace')
config_path = File.expand_path('config.json') # this will be cloud tags later
config = JSON.parse File.read config_path

Pathname(workspace_path).rmtree if File.exist? workspace_path

puts "WORKSPACE PATH:\n#{workspace_path}"
puts "CONFIG:"
pp config
puts

project = config["project"] or raise "project missing"
sha     = config["sha"]     or raise "sha missing"
arbiter = config["arbiter"] or raise "arbiter missing"
if arbiter == true
  workers = config["workers"] or raise "workers missing"
  trod_command = %W{
    trod arbiter
    --project #{project.inspect}
    --sha #{sha.inspect}
    --workers #{workers.to_json.inspect}
  }
else
  worker = config["worker"] or raise "worker missing"
  trod_command = %W{
    trod worker
    --project #{project.inspect}
    --sha #{sha.inspect}
    --type #{worker.inspect}
    --redis #{arbiter.inspect}
  }
end


command = <<-SH
  git clone --verbose -- #{project.inspect} #{workspace_path.inspect} &&
  cd #{workspace_path.inspect} &&
  git checkout  #{sha.inspect} &&
  bundle check || bundle install &&
  bundle exec #{trod_command * ' '}
SH

puts command

system(command)
