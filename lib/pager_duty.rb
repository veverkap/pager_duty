require "pager_duty/version"
require "pager_duty/configurable"
require "pager_duty/client"
require "pager_duty/connection"
require "pager_duty/default"
require "pager_duty/error"

module PagerDuty
  class << self
    include PagerDuty::Configurable

    def client
      return @client if defined?(@client)
      @client = PagerDuty::Client.new(options)
    end
  end
end
PagerDuty.setup