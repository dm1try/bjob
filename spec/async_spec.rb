require 'bjob/async'

RSpec.describe 'async job mixin' do
  subject { stub_const('SomeJob', Class.new { include BJob::Async }) }

  it 'extends subject with method for pushing async jobs' do
    expect(subject).to respond_to(:async)
  end

  context 'with working unix client' do
    let(:client) { instance_double(::BJob::Client::UNIXSocket) }

    before do
      allow(::BJob::Client::UNIXSocket).to receive(:connect).and_return(client)
    end

    it 'pushes job to the server using target class params' do
      expect(client).to receive(:push)
        .with(class_name: 'SomeJob', method: 'run', params:[])
      subject.async

      expect(client).to receive(:push)
        .with(class_name: 'SomeJob', method: 'run', params:[:first_param, :second_param])
      subject.async(:first_param, :second_param)
    end
  end
end
