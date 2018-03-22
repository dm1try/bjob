module BJob
  class Coordinator
    def initialize(pool_size: 16)
      @running_queue = Queue.new
      @pool_size = pool_size
    end

    def start
      @pool_size.times do
        Thread.new do
          loop do
            @running_queue.pop
          end
        end
      end
    end

    def schedule(job)
      :ok
    end
  end
end
