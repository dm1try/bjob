require 'bjob/client/unix_socket'
require 'socket'

RSpec.describe BJob::Client::UNIXSocket do
  let(:path) { '/tmp/bjob_test_socket' }
  subject { described_class.new(path: path) }

  before do
    FileUtils.rm(path) if File.exists?(path)
  end

  context 'some socket server is running' do
    before do
      ::UNIXServer.new(path)
    end

    it 'connects and pushes job request to server' do
      subject.connect

      subject.push(class_name: 'SomeClass', method: 'some_method', params: [])
    end
  end

  context 'socket server is down, fallback is defined' do
    let(:fallback) { ->(message) { expect(message['class']).to eq('SomeClass') } }
    subject { described_class.new(path: path, fallback: fallback) }

    before do
      subject.connect
    end

    it 'calls a fallback on pushing' do
      expect(fallback).to receive(:call)
      subject.push(class_name: 'SomeClass', method: 'some_method', params: [])
    end
  end
end
