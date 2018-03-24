require_relative 'runner'
require 'securerandom'

module BJob
  class Coordinator
    def initialize(pool_size: 16, runner: ::BJob::Runner, logger: BJob.logger, running_queue: nil, waiting_queue: nil, on_stop: nil)
      @running_queue = running_queue || SizedQueue.new(pool_size)
      @waiting_queue = waiting_queue || Queue.new
      @pool_size = pool_size
      @job_threads = []
      @runner = runner
      @logger = logger
      @on_stop = on_stop || ->(waiting_queue) {
        size = waiting_queue.size
        @logger.warn("#{size} jobs are lost") if size > 0
      }
    end

    def start
      start_scheduler_thread

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
      @running_queue.push(job, true)
    rescue ThreadError
      @waiting_queue.push(job)
    ensure
      :ok
    end

    def start_scheduler_thread
      Thread.new do
        while job = @waiting_queue.pop
          @running_queue.push(job)
        end
      end
    end

    def stop
      @job_threads.each{ |thread| thread.raise('shutdown') }
      @job_threads.each(&:join)
      @on_stop.call(@waiting_queue)
    end

    def stats
      {
        runtime: {
          running: @running_queue.size,
          waiting: @waiting_queue.size
        }
      }
    end

    private

    def generate_job_id
      SecureRandom.hex(5)
    end
  end
end
