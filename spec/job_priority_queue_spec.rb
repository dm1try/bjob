require 'bjob/job_priority_queue'

RSpec.describe BJob::JobPriorityQueue do
  context 'each item is a hash with "priority" key' do
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
end
