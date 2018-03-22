require 'bjob/coordinator'

RSpec.describe BJob::Coordinator do
  let(:job) { {'class' => 'SomeJob', 'method' => 'run', 'params' => [] } }

  describe '#start' do
    it 'runs a pool of threads for doing work' do
      expect { subject.start }.to change{ Thread.list.count }.by(16)
    end
  end

  describe '#stop' do
    it 'shutdown workers pool' do
      subject.start
      expect { subject.stop }.to change{ Thread.list.count }.by(-16)
    end
  end

  context 'coordinator started' do
    before do
      subject.start
    end

    it 'schedules a job for processing in pool' do
      expect_any_instance_of(BJob::Runner).to receive(:run).with(job)
      expect(subject.schedule(job)).to eq(:ok)
    end
  end
end
