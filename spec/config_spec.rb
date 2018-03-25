require 'bjob/config'

RSpec.describe BJob::Config do
  describe '.default' do
    it 'returns default config' do
      config = BJob::Config.default

      expect(config.concurrency).to be
      expect(config.unix_socket_path).to be
      expect(config.saved_jobs_path).to be
    end
  end

  describe '.from_argv' do
    let(:concurrency) { 4 }
    let(:unix_socket_path) { '/tmp/bjob_socket_from_command_line' }
    let(:saved_jobs_path) { '/tmp/bjob_saved_jobs_path_from_command_line' }
    let(:fake_argv) {  "-c #{concurrency} --unix-socket-path #{unix_socket_path} --saved-jobs-path #{saved_jobs_path}".split }

    it 'return config based on command line options' do
      stub_const('ARGV', fake_argv)

      config = BJob::Config.from_argv
      expect(config.concurrency).to eq(concurrency)
      expect(config.unix_socket_path).to eq(unix_socket_path)
      expect(config.saved_jobs_path).to eq(saved_jobs_path)
    end
  end
end
