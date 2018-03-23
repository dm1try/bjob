module BJob
  module Test
    class Runner
      @@jobs = []
      def self.jobs; @@jobs end
      def self.reset; @@jobs = [] end

      def run(job)
        @@jobs << job
      end
    end
  end
end
