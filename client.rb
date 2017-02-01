module TinyPuma
  class Client
    attr_reader :io, :to_io

    def initialize(io)
      @buffer = ""
      @io = io
      @to_io = io.to_io
    end

    def try_to_finish
      begin
        # tăng thời gian sleep để giả lập slow client
        sleep(0.001)
        data = @io.read_nonblock(5)
      rescue Errno::EAGAIN
        return false
      end

      @buffer << data

      if @buffer.end_with?("\r\n\r\n")
        p "Get request: #{@buffer}"
        true
      else
        false
      end
    end

    def response(result)
      @io << 200
      @io << "\n"
      @io << "#{result}\n"
      @io.close
    end
  end
end