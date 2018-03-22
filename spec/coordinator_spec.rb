require 'bjob/coordinator'
require 'bjob/test/runner'

RSpec.describe BJob::Coordinator do
  let(:job) { {'class' => 'SomeJob', 'method' => 'run', 'params' => [] } }
  let(:jobs_pool_size) { 4 }

  subject { described_class.new(runner: BJob::Test::Runner, pool_size: jobs_pool_size) }

  describe '#start' do
    it 'runs a pool of threads for doing work' do
      expect { subject.start }.to change{ Thread.list.count }.by(jobs_pool_size)
    end
  end

  describe '#stop' do
    it 'shutdown workers pool' do
      subject.start
      expect { subject.stop }.to change{ Thread.list.count }.by(-(jobs_pool_size))
    end
  end

  describe '#stats' do
    it do
      expect(subject.stats).to eq({runtime: {running: 0}})
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

    def processed_jobs
      subject.stop
      BJob::Test::Runner.jobs
    end
  end
end
