require "bundler"
Bundler.setup

require 'push_daemon'

PushDaemon.new.start
