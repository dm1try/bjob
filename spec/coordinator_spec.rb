require 'bjob/coordinator'
require 'bjob/test/runner'

RSpec.describe BJob::Coordinator do
  let(:job) { {'class' => 'SomeJob', 'method' => 'run', 'params' => [] } }
  let(:jobs_pool_size) { 4 }

  subject { described_class.new(runner: BJob::Test::Runner, pool_size: jobs_pool_size) }

  describe '#start' do
    it 'runs a pool of threads for doing work' do
      expect { subject.start }.to change{ subject.job_threads.select(&:alive?).count }.by(jobs_pool_size)
    end

    it 'runs scheduler thread' do
      expect { subject.start }.to change{ subject.scheduler_thread&.alive? }
    end
  end

  describe '#stop' do
    before do
      subject.start
    end

    it 'stops workers pool' do
      expect { subject.stop }.to change{ subject.job_threads.select(&:alive?).count }.by(-(jobs_pool_size))
    end

    it 'stops scheduler thread' do
      expect { subject.stop }.to change{ subject.scheduler_thread&.alive? }
    end
  end

  describe '#stats' do
    it do
      expect(subject.stats).to eq({runtime: {running: 0, waiting: 0}})
    end
  end

  describe '#schedule' do
    context 'running queue raises ThreadError' do
      let(:running_queue) { instance_double(SizedQueue) }
      let(:waiting_queue) { instance_double(Queue) }

      subject { described_class.new(runner: BJob::Test::Runner,
                                    running_queue: running_queue, waiting_queue: waiting_queue) }
      before do
        allow(running_queue).to receive(:push).with(job, true).and_raise(ThreadError)
      end

      it 'pushes the job to a waiting queue' do
        expect(waiting_queue).to receive(:push).with(job)
        subject.schedule(job)
      end
    end
  end

  context 'coordinator started' do
    before do
      subject.start
      BJob::Test::Runner.reset
    end

    it 'schedules a job for processing in pool' do
      subject.schedule(job)
      subject.stop

      expect(processed_jobs.first).to eq(job)
    end

    it 'schedules many jobs' do
      subject.schedule(job)
      subject.schedule(job.dup)
      subject.schedule(job.dup)
      subject.stop

      expect(processed_jobs.count).to eq(3)
    end

    it 'generates job id' do
      subject.schedule(job)
      subject.stop

      expect(processed_jobs.last['id']).to satisfy { |id| id.is_a?(String) && id.size == 10 }
    end
  end

  context 'running queue is exhausted' do
    let(:small_pool_size) { 1 }
    subject { described_class.new(runner: BJob::Test::Runner, pool_size: small_pool_size) }

    let(:first_job) { {'class' => 'FirstJob', 'method' => 'run', 'params' => [] } }
    let(:second_job) { {'class' => 'SecondJob', 'method' => 'run', 'params' => [] } }
    let(:third_job) { {'class' => 'ThirdJob', 'method' => 'run', 'params' => [] } }

    before do
      BJob::Test::Runner.reset
      subject.start
    end

    context 'there is enough time to do the work before shutdown' do
      let(:time_for_processing) { 0.01 }

      it 'processes all jobs' do
        subject.schedule(first_job)
        subject.schedule(second_job)
        subject.schedule(third_job)

        sleep time_for_processing
        subject.stop

        expect(processed_jobs.count).to eq(3)
        expect(processed_jobs).to include(first_job)
        expect(processed_jobs).to include(second_job)
        expect(processed_jobs).to include(third_job)
      end
    end

    context 'shutdown with remaining work' do
      let(:on_stop) { ->(waiting_queue){ @waiting_count = waiting_queue.size } }
      subject { described_class.new(runner: BJob::Test::Runner, pool_size: small_pool_size, on_stop: on_stop) }

      it 'processes some jobs and returns remaining to the waiting queue' do
        subject.schedule(first_job)
        subject.schedule(second_job)
        subject.schedule(third_job)

        subject.stop

        expect(processed_jobs.count + @waiting_count).to eq(3)
      end
    end
  end

  describe 'on_stop callback' do
    let(:waiting_queue) { Queue.new }

    it 'calls a provided callback with a waiting queue on stopping' do
      callback = ->(queue) { expect(queue).to eq(waiting_queue) }

      coordinator = described_class.new(waiting_queue: waiting_queue, on_stop: callback)
      coordinator.start
      coordinator.stop
    end
  end

  def processed_jobs
    retry_count = 0
    loop do
      raise 'working threads still alive' if retry_count > 3
      break if subject.job_threads.select(&:alive?).count.zero?
      sleep 0.1
      retry_count +=1
    end

    BJob::Test::Runner.jobs
  end
end
