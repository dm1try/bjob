class BJob::Runner

  def initialize(logger: BJob.logger)
    @logger = logger
  end

  def run(job)
    job_const =
      begin
        Object.const_get(job['class'])
      rescue NameError
        @logger.warn("missing constant #{job['class']}, skipping job...")
        return
      end

    method = job['method']
    params = job['params']
    job_const.new.send(method, *params)
  end
end
