module TinyPuma
  class Reactor
    def initialize(threadpool)
      @threadpool = threadpool
      @mutex = Mutex.new
      @sockets = []
      Thread.new do
        while true
          if @sockets.size > 0
            ready = IO.select @sockets
            if ready and reads = ready[0]
              reads.each do |c|
                if c.try_to_finish
                  @threadpool.add c
                  @mutex.synchronize do
                    @sockets.delete c
                  end
                end
              end
            end
          end
        end
      end
    end

    def add(client)
      @mutex.synchronize do
        @sockets << client
      end
    end
  end
end
