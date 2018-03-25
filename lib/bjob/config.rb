require 'ostruct'

module BJob
  class Config
    def self.default
      @config ||= begin
        config = OpenStruct.new
        config.concurrency = 16
        config.unix_socket_path = ENV['BJOB_SOCKET_PATH'] || '/tmp/bjob_socket'
        config.saved_jobs_path = ENV['BJOB_SAVED_JOBS_PATH'] || '/tmp/bjob_saved_jobs'
        config
      end
    end
  end
end
