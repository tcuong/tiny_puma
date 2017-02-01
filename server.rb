require 'rubygems'
require 'socket'
require './client'
require './reactor'
require './thread_pool'

module TinyPuma
  Thread::abort_on_exception = true

  class Server
    def run
      socket = ::TCPServer.new("127.0.0.1", 3000)
      socket.listen 1024

      @threadpool = TinyPuma::ThreadPool.new(1,10) do |client|
        sleep(1)
        client.response("OK")
      end

      @reactor = TinyPuma::Reactor.new(@threadpool)

      while true
        ios = IO.select [socket]
        ios.first.each do |sock|
          begin
            if io = sock.accept_nonblock
              @reactor.add Client.new(io)
            end
          rescue Errno::ECONNABORTED
            io.close rescue nil
          end
        end
      end
    end
  end
end

TinyPuma::Server.new.run