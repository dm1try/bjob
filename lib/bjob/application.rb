require_relative 'coordinator'
require_relative 'runner'
require_relative 'backend/unix_socket'
require_relative 'persistence/saved_queue'

module BJob
  class Application

    def start
      saved_jobs_path = ENV['BJOB_SAVED_JOBS_PATH'] || '/tmp/bjob_saved_jobs'
      saved_queue = BJob::Persistence::SavedQueue.new(filename: saved_jobs_path)

      saved_jobs_queue = saved_queue.load

      if saved_jobs_queue.size > 0
        puts "#{saved_jobs_queue.size} jobs are loaded from #{saved_jobs_path}"
      end

      on_stop = ->(waiting_queue) do
        if waiting_queue.size > 0
          puts "#{waiting_queue.size} jobs will be saved to #{saved_jobs_path}"
          saved_queue.save(waiting_queue)
        end
      end

      coordinator = ::BJob::Coordinator.new(waiting_queue: saved_jobs_queue, on_stop: on_stop)

      backends = []
      socket_path = ENV['BJOB_SOCKET_PATH'] || '/tmp/bjob_socket'
      unix_socket_backend = ::BJob::Backend::UNIXSocket.new(coordinator: coordinator, path: socket_path)
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
