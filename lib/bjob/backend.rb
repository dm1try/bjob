module BJob
  class Backend

    def initialize(coordinator:)
      @coordinator = coordinator
    end

    def start
      raise 'should return a new backend thread'
    end

    def process_job(job)
      @coordinator.schedule(job)
    end
  end
end
