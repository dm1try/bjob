require_relative 'client/unix_socket'

module BJob
  module Async
    def self.included(target)
      target.extend ClassMethods
    end

    module ClassMethods
      def async(*params)
        Thread.current[:bjob_client] ||= ::BJob::Client::UNIXSocket.connect
        Thread.current[:bjob_client].push(class_name: self.name, method: 'run', params: params)
      end
    end
  end
end
