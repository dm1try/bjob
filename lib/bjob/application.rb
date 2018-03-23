require_relative 'coordinator'
require_relative 'runner'
require_relative 'backend/unix_socket'

module BJob
  class Application

    def start
      coordinator = ::BJob::Coordinator.new

      backends = []
      socket_path = ENV['socket_path'] || '/tmp/bjob_socket'
      unix_socket_backend = ::BJob::Backend::UNIXSocket.new(coordinator: coordinator, path: socket_path)
      backends << unix_socket_backend

      trap('INT') do
        puts 'Bye-Bye!'
        exit 0
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
