require "bundler"
Bundler.setup

require 'eventmachine'

class MyServer < EM::Connection
  def receive_data(data)
    p "called: receive_data(#{data.inspect}) "
  end
end

EventMachine::run do
  @socket = EM::open_datagram_socket "127.0.0.1", 6889, MyServer
end

# bundle exec ruby ./pushd-em.rb
# echo "PING" | nc -u 127.0.0.1 6889
# echo 'SEND abc123 "Hello, World!"' | nc -u 127.0.0.1 6889
