require 'bjob/persistence/file'

RSpec.describe BJob::Persistance::File do
  let(:filename) { '/tmp/bjob_persisted_work' }
  subject { described_class.new(filename: filename) }

  let(:some_job) { {'id' => 'some_id', 'some_data' => 'data'} }
  let(:another_job) { {'id' => 'another_id', 'another_data' => 'data'} }

  it 'saves jobs to the file and shift them back' do
    subject.save(some_job)
    subject.save(another_job)

    expect(subject.shift).to eq(some_job)
    expect(subject.shift).to eq(another_job)
  end
end
