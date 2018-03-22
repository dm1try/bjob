class BJob::Runner
  def run(job)
    job_const = Object.const_get(job['class'])
    method = job['method']
    params = job['params']
    job_const.new.send(method, *params)
  end
end
