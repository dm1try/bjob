require_relative 'runner'
require_relative 'priority_queue'
require 'securerandom'

module BJob
  class Coordinator
    attr_reader :job_threads, :scheduler_thread

    def initialize(pool_size: 16, runner: ::BJob::Runner, logger: BJob.logger, running_queue: nil, waiting_queue: nil, on_stop: nil)
      @running_queue = running_queue || SizedQueue.new(pool_size)
      @waiting_queue = waiting_queue || JobPriorityQueue.new
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
      job['priority'] = 0 if job['priority'].nil?
      @running_queue.push(job, true)
    rescue ThreadError
      @waiting_queue.push(job)
    ensure
      :ok
    end

    def start_scheduler_thread
      Thread.handle_interrupt(RuntimeError => :never) do
        @scheduler_thread = Thread.new do
          Thread.handle_interrupt(RuntimeError => :on_blocking) do
            while job = @waiting_queue.pop
              Thread.handle_interrupt(RuntimeError => :on_blocking) do
                @running_queue.push(job)
              rescue
                @waiting_queue.push(job)
                Thread.exit
              end
            end
          rescue
            Thread.exit
          end
        end
      end
    end

    def stop
      @scheduler_thread.raise('shutdown')
      @scheduler_thread.join

      @on_stop.call(@waiting_queue)

      @job_threads.each{ |thread| thread.raise('shutdown') }
      @job_threads.each(&:join)
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
