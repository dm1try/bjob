require 'bjob/coordinator'

RSpec.describe BJob::Coordinator do
  let(:job) { {some: :job} }

  it 'schedules a job' do
    expect(subject.schedule(job)).to eq(:ok)
  end
end
