require 'bjob/backend/unix_socket'
require 'json'
require 'socket'

RSpec.describe BJob::Backend::UNIXSocket do
  let(:coordinator) { double(:coordinator, schedule: :ok) }
  let(:socket_path) { '/tmp/test_socket' }

  subject { described_class.new(path: socket_path, coordinator: coordinator) }

  after do
    FileUtils.rm(socket_path) if File.exist?(socket_path)
  end

  context 'with valid JSON formatted request from client' do
    let(:some_job) { {'some' => 'job'} }
    let(:client_request) { JSON.dump(some_job) }

    it 'transfers request from client to coordinator using unix socket' do
      expect(coordinator).to receive(:schedule).with(some_job)

      subject.start
      sleep 0.1 # TODO: re-check
      send_request
    end

    def send_request
      UNIXSocket.new(socket_path).puts(client_request)
    end
  end

  context 'socket file already exists in the system' do
    before do
      FileUtils.touch(socket_path)
    end

    it 'removes socket file if it exists' do
      expect{subject.start}.not_to raise_error(Errno::EADDRINUSE)
    end
  end
end
