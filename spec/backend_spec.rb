require 'bjob/backend'

RSpec.describe BJob::Backend do
  let(:working_pool) { double(:working_pool, schedule: :ok) }
  subject { described_class.new(working_pool: working_pool) }

  let(:some_job) { {some: :job} }

  it 'delegates job scheduling to the working_pool' do
    expect(working_pool).to receive(:schedule).with(some_job)
    subject.process_job(some_job)
  end
end
