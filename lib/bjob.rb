require "bjob/version"
require 'logger'

module BJob
  ENV_KEY = 'BJOB_ENV'

  def self.logger
    @logger ||=
      begin
        level =
          case ENV[ENV_KEY]
          when 'production'
            Logger::WARN
          when 'test'
            Logger::ERROR
          when 'development'
            Logger::DEBUG
          else
            Logger::INFO
          end

        Logger.new(STDOUT, level: level)
      end
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.inline!
    @inline = true
  end

  def self.inline?
    !!@inline
  end
end
