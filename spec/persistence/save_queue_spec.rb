require 'bjob/persistence/saved_queue'

RSpec.describe BJob::Persistence::SavedQueue do
  subject { described_class.new(filename: '/tmp/bjob_persisted_queue') }
  let(:items) { [{'id'=>'first','id'=>'second'}] }

  let(:initial_queue) do
    queue = Queue.new
    queue_items = items.dup

    while item = queue_items.shift
      queue.push(item)
    end

    queue
  end

  it 'saves and load in-memory queue' do
    subject.save(initial_queue)
    loaded_queue = subject.load

    loaded_items = []

    while item = loaded_queue.shift(true) rescue nil
      loaded_items.push(item)
    end

    expect(loaded_items).to eq(items)
  end
end
