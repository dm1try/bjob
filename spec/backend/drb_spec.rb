require 'bjob/backend/drb'

RSpec.describe BJob::Backend::DRb do
  let(:working_pool) { double(:working_pool, schedule: :ok) }
  let(:drb_uri) { 'druby://localhost:8787' }

  subject { described_class.new(uri: drb_uri, working_pool: working_pool) }

  context 'with valid job data' do
    let(:some_job) { {'some' => 'job'} }

    it 'adds a job for processing' do
      expect(working_pool).to receive(:schedule).with(some_job)

      subject.start
      sleep 0.1
      send_request
    end

    def send_request
      backend = ::DRbObject.new_with_uri("druby://localhost:8787")
      backend.process_job(some_job)
    end
  end
end
