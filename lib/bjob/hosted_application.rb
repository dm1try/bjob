require 'pathname'

module BJob
  class HostedApplication
    Config = Struct.new(:boot_path, :init_cmd)

    def self.bootstrap(config)
      boot_path = if config.boot_path
        boot_path = Pathname.new(config.boot_path)
        boot_path = boot_path.expand_path(Dir.pwd) if boot_path.relative?
        boot_path.to_s
      end
      require boot_path if boot_path

      eval(config.init_cmd) if config.init_cmd
    end
  end
end
