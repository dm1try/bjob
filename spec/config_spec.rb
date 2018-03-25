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
end
