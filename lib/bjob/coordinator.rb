require_relative 'runner'

module BJob
  class Coordinator
    def initialize(pool_size: 16)
      @running_queue = Queue.new
      @pool_size = pool_size
      @job_threads = []
    end

    def start
      @job_threads = @pool_size.times.map do
        Thread.handle_interrupt(RuntimeError => :never) do
          Thread.new do
            loop do
              # allow kill a thread only on blocking by an empty queue
              job = Thread.handle_interrupt(RuntimeError => :on_blocking) do
                @running_queue.pop
              rescue
                Thread.exit
              end

              ::BJob::Runner.new.run(job)
            end
          end
        end
      end
    end

    def schedule(job)
      @running_queue.push(job)

      :ok
    end

    def stop
      @job_threads.each{ |thread| thread.raise('shutdown') }
      @job_threads.each(&:join)
    end
  end
end
