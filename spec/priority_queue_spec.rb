require 'bjob/priority_queue'

RSpec.describe BJob::PriorityQueue do
  context 'each item is a hash with "priority" key' do
    let(:comparator) { ->(l,r) { l['priority'] <=> r['priority'] } }
    let(:subject) { described_class.new(comparator: comparator) }

    it 'pops items based on their priority' do
      subject.push({'id' => 'low', 'priority' => 1})
      subject.push({'id' => 'high', 'priority' => 5})
      subject.push({'id' => 'default', 'priority' => 2})
      subject.push({'id' => 'default2', 'priority' => 4})
      subject.push({'id' => 'low2', 'priority' => 1})
      subject.push({'id' => 'default2', 'priority' => 2})
      subject.push({'id' => 'default2', 'priority' => 4})
      subject.push({'id' => 'high2', 'priority' => 2})
      subject.push({'id' => 'high2', 'priority' => 3})

      expect(subject.pop).to eq({'id' => 'high', 'priority' => 5})
      expect(subject.pop).to include({'priority' => 4})
      expect(subject.pop).to include({'priority' => 4})
      expect(subject.pop).to include({'priority' => 3})
      expect(subject.pop).to include({'priority' => 2})
      expect(subject.pop).to include({'priority' => 2})
      expect(subject.pop).to include({'priority' => 2})
      expect(subject.pop).to include({'priority' => 1})
      expect(subject.pop).to include({'priority' => 1})
    end

  end

  context 'multi-threading' do
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
end
