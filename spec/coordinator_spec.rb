require 'bjob/coordinator'

RSpec.describe BJob::Coordinator do
  let(:job) { {some: :job} }

  describe '#start' do
    it 'runs a pool of threads for doing work' do
      expect { subject.start }.to change{ Thread.list.count }.by(16)
    end
  end

  it 'schedules a job' do
    expect(subject.schedule(job)).to eq(:ok)
  end
end
