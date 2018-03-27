require_relative 'coordinator'
require_relative 'runner'
require_relative 'backend/unix_socket'
require_relative 'persistence/saved_queue'
require_relative 'config'

module BJob
  class Application

    def start(config = BJob::Config.default)
      saved_queue = BJob::Persistence::SavedQueue.new(filename: config.saved_jobs_path)

      saved_jobs_queue = Queue.new
      saved_queue.populate(saved_jobs_queue)

      if saved_jobs_queue.size > 0
        puts "#{saved_jobs_queue.size} jobs are loaded from #{config.saved_jobs_path}"
      end

      on_stop = ->(waiting_queue) do
        if waiting_queue.size > 0
          puts "#{waiting_queue.size} jobs will be saved to #{config.saved_jobs_path}"
          saved_queue.save(waiting_queue)
        end
      end

      coordinator = ::BJob::Coordinator.new(waiting_queue: saved_jobs_queue,
                                            pool_size: config.concurrency, on_stop: on_stop)

      backends = []
      unix_socket_backend = ::BJob::Backend::UNIXSocket.new(coordinator: coordinator, path: config.unix_socket_path)
      backends << unix_socket_backend

      ['TSTP', 'TERM', 'INT'].each do |stop_signal|
        trap(stop_signal) do
          puts "\nwaiting for completion running jobs..."
          coordinator.stop
          puts 'Bye-Bye!'
          exit 0
        end
      end

      trap('USR1') do
        puts coordinator.stats
      end

      print_hello_message

      coordinator.start
      backends.map(&:start).each(&:join)
    end

    private

    def print_hello_message
      puts %q{
   (                    )
 ( )\     (          ( /(
 )((_)    )\    (    )\())
((_)_    ((_)   )\  ((_)\
 | _ )  _ | |  ((_) | |(_)
 | _ \ | || | / _ \ | '_ \
 |___/  \__/  \___/ |_.__/

 I'm ready man :)
      } if ENV['BJOB_ENV'] == 'development'
    end
  end
end
