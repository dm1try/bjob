require_relative 'client/unix_socket'

module BJob
  module Async
    PRIORITIES = {low: -1, normal: 0, high: 1}

    def self.included(target)
      target.extend ClassMethods
      target.instance_variable_set(:@meta, {'priority': 0})
    end

    module ClassMethods
      def async(*params)
        Thread.current[:bjob_client] ||= ::BJob::Client::UNIXSocket.connect
        Thread.current[:bjob_client].push(class_name: self.name, method: 'run', params: params, **@meta)
      end

      def meta(options)
        @meta.update(options)
      end

      def priority(priority)
        new_priority = if priority.is_a?(Symbol)
          PRIORITIES[priority] || raise("wrong priority value! allowed values: #{PRIORITIES.keys}")
        elsif priority.is_a?(Integer)
          priority
        else
          raise 'unsupported value!'
        end

        meta(priority: new_priority)
      end
    end
  end
end
