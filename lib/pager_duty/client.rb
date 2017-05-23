require "pager_duty/configurable"
require "pager_duty/connection"
require "pager_duty/client/abilities"
require "pager_duty/client/addons"
require "pager_duty/client/escalation_policies"
require "pager_duty/client/incidents"

module PagerDuty
  class Client
    include PagerDuty::Configurable
    include PagerDuty::Connection
    include PagerDuty::Client::Abilities
    include PagerDuty::Client::Addons
    include PagerDuty::Client::EscalationPolicies
    include PagerDuty::Client::Incidents

    def initialize(options = {})
      # Use options passed in, but fall back to module defaults
      PagerDuty::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || PagerDuty.instance_variable_get(:"@#{key}"))
      end
    end

    def api_token=(value)
      reset_agent
      @api_token = value
    end
  end
end