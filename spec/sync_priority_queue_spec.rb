require 'bjob/sync_priority_queue'

RSpec.describe BJob::SyncPriorityQueue do
  let(:item) { 1 }

  it 'locks at empty size' do
    add_item_later

    expect(subject.pop).to eq(item)
  end

  def add_item_later
    Thread.new do
      sleep 0.1
      subject.push(item)
    end
  end
end
