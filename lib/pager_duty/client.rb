require "pager_duty/configurable"
require "pager_duty/connection"
require "pager_duty/client/abilities"
require "pager_duty/client/addons"
require "pager_duty/client/escalation_policies"
require "pager_duty/client/incidents"
require "pager_duty/client/log_entries"
require "pager_duty/client/maintenance_windows"
require "pager_duty/client/notifications"
require "pager_duty/client/on_calls"

module PagerDuty
  class Client
    include PagerDuty::Configurable
    include PagerDuty::Connection
    include PagerDuty::Client::Abilities
    include PagerDuty::Client::Addons
    include PagerDuty::Client::EscalationPolicies
    include PagerDuty::Client::Incidents
    include PagerDuty::Client::LogEntries
    include PagerDuty::Client::MaintenanceWindows
    include PagerDuty::Client::Notifications
    include PagerDuty::Client::OnCalls

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