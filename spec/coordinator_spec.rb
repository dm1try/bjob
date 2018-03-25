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
      subject.schedule(job)
      subject.schedule(job)

      expect(processed_jobs.count).to eq(3)
    end

    it 'generates job id' do
      subject.schedule(job)

      expect(processed_jobs.last['id']).to satisfy { |id| id.is_a?(String) && id.size == 10 }
    end

    context 'running queue is exhausted' do
      subject { described_class.new(runner: BJob::Test::Runner, pool_size: 1) }

      before do
        allow_any_instance_of(BJob::Test::Runner).to receive(:run).and_wrap_original do |original, *args|
          sleep 0.01
          original.call(*args)
        end
      end

      it 'uses waiting queue for the sheduling' do
        subject.schedule(job)
        subject.schedule(job)

        expect(processed_jobs.count).to eq(2)
      end
    end

    def processed_jobs
      subject.stop
      BJob::Test::Runner.jobs
    end
  end

  describe 'on_stop callback' do
    let(:waiting_queue) { instance_double(Queue) }

    it 'calls a provided callback with a waiting queue on stopping' do
      callback = ->(queue) { expect(queue).to eq(waiting_queue) }
      described_class.new(waiting_queue: waiting_queue, on_stop: callback).stop
    end
  end
end
