require 'ostruct'
require 'optparse'

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

    def self.from_argv
      config = default.dup

      OptionParser.new do |opts|
        opts.banner = "Usage: bjob [options]"

        opts.on("-c", "--concurrency COUNT", Integer, "number of threads used for processing jobs") do |v|
          config.concurrency = v
        end

        opts.on("", "--unix-socket-path UNIX_SOCKET_PATH", "socket path for listening for job requests") do |v|
          config.unix_socket_path = v
        end

        opts.on("", "--saved-jobs-path SAVED_JOBS_PATH", "path for storing unfinished jobs") do |v|
          config.saved_jobs_path = v
        end
      end.parse!

      config
    end
  end
end
