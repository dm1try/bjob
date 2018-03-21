require 'bjob/backend'

RSpec.describe BJob::Backend do
  let(:coordinator) { double(:coordinator, schedule: :ok) }
  subject { described_class.new(coordinator: coordinator) }

  let(:some_job) { {some: :job} }

  it 'delegates job scheduling to the coordinator' do
    expect(coordinator).to receive(:schedule).with(some_job)
    subject.process_job(some_job)
  end
end
