module BJob
  class Runner
    def initialize(logger: BJob.logger)
      @logger = logger
    end

    def run(job)
      @logger.info("job ##{job['id']} started")
      start_time = Time.now

      job_const =
        begin
          Object.const_get(job['class'])
        rescue NameError
          @logger.warn("missing constant #{job['class']}, skipping job...")
          return
        end

      method = job['method']
      params = job['params']

      begin
        result = job_const.new.send(method, *params)
        @logger.info("job ##{job['id']} done: #{elapsed_time(start_time)} ms")
        result
      rescue StandardError => error
        @logger.error("job ##{job['id']} failed: #{error}")
        nil
      end
    end

    private

    def elapsed_time(start_time)
      Time.now - start_time
    end
  end
end
