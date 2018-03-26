require_relative '../client'
require 'socket'
require 'json'

module BJob
  class Client::UNIXSocket < Client
    def initialize(path:, fallback: nil)
      @path = path
      @fallback = fallback
      @disconnected = false
    end

    def connect
      @socket = ::UNIXSocket.new(@path)
      @disconnected = true if @socket.nil?
    rescue Errno::ECONNREFUSED, Errno::ENOENT
      @disconnected = true
    ensure
      self
    end

    def self.connect(path = nil)
      path ||= ENV['BJOB_SOCKET_PATH'] || '/tmp/bjob_socket'
      new(path: path).connect
    end

    def push(class_name:, method:, params:)
      message = {'class' => class_name, 'method' => method, 'params' => params}

      if !@disconnected
        @socket.puts(encode_message(message))
      else
        @fallback.call(message) if @fallback
      end
    end

    private

    def encode_message(message)
      JSON.dump(message)
    end
  end
end
