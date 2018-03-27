require_relative 'file'

module BJob
  module Persistence
    class SavedQueue

      def initialize(filename:)
        @filename = filename
      end

      def populate(queue)
        saved_file = BJob::Persistence::File.new(filename: @filename)

        while saved_item = saved_file.shift
          queue.push(saved_item)
        end

        saved_file.close
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
