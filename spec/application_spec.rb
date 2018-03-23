require 'bjob/application'

RSpec.describe BJob::Application do
  describe '#start' do
    let(:coordinator) { instance_double(BJob::Coordinator, start: true) }
    let(:unix_socket_backend) { instance_double(BJob::Backend::UNIXSocket, start: Thread.new {}) }

    before do
      allow(BJob::Coordinator).to receive(:new).and_return(coordinator)
      allow(BJob::Backend::UNIXSocket).to receive(:new).and_return(unix_socket_backend)
    end

    it 'configures and run an application stack' do
      expect(BJob::Backend::UNIXSocket).to receive(:new).with(hash_including(coordinator: coordinator))

      expect(coordinator).to receive(:start)
      expect(unix_socket_backend).to receive(:start)

      subject.start
    end
  end
end
