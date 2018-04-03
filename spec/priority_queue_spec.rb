require 'bjob/priority_queue'

RSpec.describe BJob::PriorityQueue do
  it 'pops items based on their priority' do
    subject.push(1)
    subject.push(3)
    subject.push(2)

    expect(subject.pop).to eq(3)
    expect(subject.pop).to eq(2)
    expect(subject.pop).to eq(1)
  end

  describe '#size' do
    it do
      subject.push(1)
      expect(subject.size).to eq(1)
    end
  end
end
