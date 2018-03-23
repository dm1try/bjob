require 'bjob/client/unix_socket'
require 'socket'

RSpec.describe BJob::Client::UNIXSocket do
  let(:path) { '/tmp/bjob_test_socket' }
  subject { described_class.new(path: path) }

  context 'some socket server is running' do
    before do
      FileUtils.rm(path) if File.exists?(path)
      ::UNIXServer.new(path)
    end

    it 'connects and pushes job request to server' do
      subject.connect

      subject.push(class_name: 'SomeClass', method: 'some_method', params: [])
    end
  end
end
