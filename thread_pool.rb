module TinyPuma
  class ThreadPool
    def initialize(min, max, &block)
      @mutex = Mutex.new
      @have_work = ConditionVariable.new

      @min = min
      @max = max

      @works = []

      @waiting = 0
      @spawned = 0

      @block = block

      min.times do
        spawn_thread
      end
    end

    def add(c)
      @mutex.synchronize do
        @works << c

        @have_work.signal
        if @waiting < @works.size and @spawned < @max
          spawn_thread
        end
      end
    end

    def spawn_thread
      @spawned += 1
      puts "Spawned new thread: #{@spawned}"

      Thread.new do
        while true do
          work = nil

          @mutex.synchronize do
            while @works.empty?
              @waiting += 1
              @have_work.wait @mutex
              @waiting -= 1
            end
            work = @works.shift
          end

          if work
            @block.call(work)
          end
        end
      end
    end
  end
end
