require 'sdbm'
require 'json'

module BJob
  module Persistance
    class File
      def initialize(filename:)
        @db = SDBM.open(filename)
      end

      def save(job)
        @db.store(job['id'], JSON.dump(job))
      end

      def shift
        key, job_dump = @db.shift
        JSON.load(job_dump) if job_dump
      end

      def close
        @db.close
      rescue SDBMError
        nil
      end
    end
  end
end
