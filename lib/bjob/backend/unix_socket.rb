require_relative '../backend'
require 'socket'
require 'json'

module BJob
  class Backend::UNIXSocket < Backend

    def initialize(path:, **opts)
      super(opts)
      @path = path
    end

    def start
      FileUtils.rm(@path) if File.exist?(@path)

      @server         = ::UNIXServer.new(@path)
      @read_sockets   = [@server]

      Thread.new do
        loop do
          read_sockets, _, _ = IO.select(@read_sockets, [])
          read_data(read_sockets)
        end
      end
    end

    def read_data(sockets)
      sockets.each do |socket|
        if socket == @server
          conn = socket.accept
          @read_sockets << conn
        else
          message = socket.gets
          job_request = decode_message(message)
          process_job(job_request)
        end
      end

    end

    private

    def decode_message(message)
      JSON.parse(message)
    end
  end
end
