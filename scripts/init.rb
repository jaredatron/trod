#!/usr/bin/env ruby

require 'pathname'

WORKSPACE_PATH = File.expand_path('workspace')

CONFIG = {
  :project => '/Volumes/Chest/deadlyicon/Work/example_trod_project',
  :sha => '499be2eee4df387a34e21e9afb5c3e3534d56e71',
}

Pathname(WORKSPACE_PATH).rmtree if File.exist? WORKSPACE_PATH

command = <<-SH
  git clone --verbose -- #{CONFIG[:project].inspect} #{WORKSPACE_PATH.inspect} &&
  cd #{WORKSPACE_PATH.inspect} &&
  git checkout  #{CONFIG[:sha].inspect} &&
  bundle check || bundle install &&
  bundle exec trod worker
SH

puts command

exec(command)
