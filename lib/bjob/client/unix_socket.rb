require_relative '../client'
require 'socket'
require 'json'

module BJob
  class Client::UNIXSocket < Client
    DEFAULT_RETRY_DELAY = 5

    def initialize(path:, fallback: nil, retry_delay: DEFAULT_RETRY_DELAY)
      @path = path

      @fallback = fallback
      @disconnected = false
      @last_retry_time = nil
      @retry_delay = retry_delay
    end

    def connect
      @socket = ::UNIXSocket.new(@path)
      @disconnected = @socket.nil?
      self
    rescue Errno::ECONNREFUSED, Errno::ENOENT
      @disconnected = true

      if should_retry?
        @last_retry_time = Time.now
        retry
      end

      self
    end

    def self.connect(path = nil)
      path ||= ENV['BJOB_SOCKET_PATH'] || '/tmp/bjob_socket'
      new(path: path).connect
    end

    def push(class_name:, method:, params:,**meta)
      message = {'class' => class_name, 'method' => method, 'params' => params}

      if !@disconnected
        @socket.puts(encode_message(message))
      else
        connect if should_retry?

        if !@disconnected
          @socket.puts(encode_message(message))
        elsif @fallback
          @fallback.call(message)
        end
      end
    rescue Errno::EPIPE
      @socket.close_write
      @disconnected = true
      connect
      retry
    end

    private

    def should_retry?
      @last_retry_time.nil? || ((Time.now - @last_retry_time) > @retry_delay)
    end

    def encode_message(message)
      JSON.dump(message)
    end
  end
end
