module BJob
  class Backend

    def initialize(working_pool:)
      @working_pool = working_pool
    end

    def start
      raise 'should return a new backend thread'
    end

    def process_job(job)
      @working_pool.schedule(job)
    end
  end
end
