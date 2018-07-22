require_relative '../backend'
require 'drb/drb'

module BJob
  class Backend::DRb < Backend

    def initialize(uri:, **opts)
      super(opts)
      @uri = uri
    end

    def start
      ::DRb.start_service(@uri, self)
    end
  end
end
