require_relative 'runner'

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
            job = @running_queue.pop
            BJob::Runner.new.run(job)
          end
        end
      end
    end

    def schedule(job)
      @running_queue.push(job)

      :ok
    end
  end
end
