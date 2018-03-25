require_relative 'file'

module BJob
  module Persistence
    class SavedQueue

      def initialize(filename:, queue_class: Queue)
        @filename = filename
        @queue_class = queue_class
      end

      def load
        saved_file = BJob::Persistence::File.new(filename: @filename)
        saved_queue = @queue_class.new

        while saved_item = saved_file.shift
          saved_queue.push(saved_item)
        end

        saved_file.close

        saved_queue
      end

      def save(queue)
        saved_file = BJob::Persistence::File.new(filename: @filename)

        while item = queue.pop(true)
          saved_file.save(item)
        end
      rescue ThreadError
        nil
      ensure
        saved_file.close
      end
    end
  end
end
