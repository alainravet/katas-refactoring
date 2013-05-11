require "bundler"
Bundler.setup

require_relative 'lib/push_daemon'
PushDaemon.new('AIzaSyCABSTd47XeIH', port: 6889)
