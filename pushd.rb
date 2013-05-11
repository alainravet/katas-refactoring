require "bundler"
Bundler.setup

require_relative 'lib/push_daemon'
PushDaemon.new
