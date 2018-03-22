require_relative 'runner'
require 'securerandom'

module BJob
  class Coordinator
    def initialize(pool_size: 16, runner: ::BJob::Runner, logger: BJob.logger)
      @running_queue = Queue.new
      @pool_size = pool_size
      @job_threads = []
      @runner = runner
      @logger = logger
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

              @runner.new.run(job)
            end
          end
        end
      end
    end

    def schedule(job)
      job['id'] = generate_job_id
      @running_queue.push(job)

      :ok
    end

    def stop
      @job_threads.each{ |thread| thread.raise('shutdown') }
      @job_threads.each(&:join)
    end

    def stats
      {
        runtime: {
          running: @running_queue.size
        }
      }
    end

    private

    def generate_job_id
      SecureRandom.hex(5)
    end
  end
end
