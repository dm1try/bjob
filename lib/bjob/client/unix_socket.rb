require_relative '../client'
require 'socket'
require 'json'

module BJob
  class Client::UNIXSocket < Client
    def initialize(path:)
      @path = path
    end

    def connect
      @socket = ::UNIXSocket.new(@path)
      raise "unable to connect to #{@path}" if @socket.nil?
      self
    end

    def self.connect(path = nil)
      path ||= ENV['BJOB_SOCKET_PATH'] || '/tmp/bjob_socket'
      new(path: path).connect
    end

    def push(class_name:, method:, params:)
      @socket.puts(encode_message('class' => class_name, 'method' => method, 'params' => params))
    end

    private

    def encode_message(message)
      JSON.dump(message)
    end
  end
end
