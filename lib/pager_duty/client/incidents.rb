require "time"
module PagerDuty
  class Client
    # Module encompassing interactions with the escalation policies API endpoint
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Escalation_Policies
    module Incidents
      # List incidents
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :since The start of the date range over which you want to search ISO8601 format
      # @option options [String] :until The end of the date range over which you want to search ISO8601 format
      # @option options [String] :date_range When set to <tt>:all</tt>, the since and until parameters and defaults are ignored.
      # @option options [Array<String>] :statuses Return only incidents with the given statuses (one or more of <tt>triggered</tt>, <tt>acknowledged</tt> or <tt>resolved</tt>. (More status codes may be introduced in the future.)
      # @option options [String] :incident_key Incident de-duplication key. Incidents with child alerts do not have an incident key; querying by incident key will return incidents whose alerts have alert_key matching the given incident key.
      # @option options [Array<String>] :service_ids Returns only the incidents associated with the passed service(s). This expects one or more service IDs.
      # @option options [Array<String>] :team_ids An array of team IDs. Only results related to these teams will be returned. Account must have the <tt>`teams`</tt> ability to use this parameter.
      # @option options [Array<String>] :user_ids Returns only the incidents currently assigned to the passed user(s). This expects one or more user IDs. Note: When using the assigned_to_user filter, you will only receive incidents with statuses of triggered or acknowledged. This is because resolved incidents are not assigned to any user.
      # @option options [Array<String>] :urgencies Array of the urgencies of the incidents to be returned. Defaults to all urgencies. Account must have the urgencies ability to do this. (<tt>:high</tt> or <tt>:low</tt>)
      # @option options [String] :time_zone Time zone in which dates in the result will be rendered.
      # @option options [String] :sort_by Used to specify both the field you wish to sort the results on (incident_number/created_at/resolved_at/urgency), as well as the direction (asc/desc) of the results. The sort_by field and direction should be separated by a colon. A maximum of two fields can be included, separated by a comma. Sort direction defaults to <tt>ascending</tt>. NOTE: The account must have the <tt>`urgencies`</tt> ability to sort by the urgency.
      # @option options [Array<String>] :include Array of additional details to include. (One or more of <tt>users</tt>, <tt>services</tt>, <tt>first_trigger_log_entries</tt>, <tt>escalation_policies</tt>, <tt>teams</tt>, <tt>assignees</tt>, <tt>acknowledgers</tt>)
      # 
      # @return [Array<Sawyer::Resource>] An array of hashes representing incidents
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Incidents/get_incidents
      def incidents(options = {})
        query_params = Hash.new
        if options[:date_range]
          # they passed in a value and we'll assume it's all
          query_params[:date_range] = "all"
        else
          query_params[:since] = options[:since].utc.iso8601 if options[:since]
          query_params[:until] = options[:until].utc.iso8601 if options[:until]
        end
        query_params[:incident_key]   = options[:incident_key] if options[:incident_key]
        query_params[:time_zone]      = options[:time_zone] if options[:time_zone]
        query_params[:sort_by]        = options[:sort_by] if options[:sort_by]

        user_ids = options.fetch(:user_ids, [])
        team_ids = options.fetch(:team_ids, [])

        query_params["statuses"]      = options.fetch(:statuses, [])
        query_params["service_ids[]"] = options[:service_ids].join(", ") if options[:service_ids]
        query_params["team_ids[]"]    = team_ids.join(",") if team_ids.length > 0
        query_params["user_ids[]"]    = user_ids.join(",") if user_ids.length > 0
        query_params["urgencies"]     = options[:urgencies] if options[:urgencies]
        query_params["include"]       = options[:include] if options[:include]

        response = get "/incidents", options.merge({query: query_params})
        response[:incidents]
      end
      alias :list_incidents :incidents

      # Show detailed information about an incident. Accepts either an incident id, or an incident number.
      # /incidents/{id}
      # 
      # @param id [String] An incident id, or an incident number
      # @param options [Sawyer::Resource] A customizable set of options.
      # 
      # @return [Sawyer::Resource] A hash representing incident
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Incidents/get_incidents_id
      def incident(id, options = {})
        response = get "/incidents/#{id}", options
        response[:incident]
      end
      alias :get_incident :incident

      # List alerts for the specified incident.
      # /incidents/{id}/alerts
      def get_alerts_incidents()
      end      

      # Show detailed information about an alert. Accepts an alert id.
      # /incidents/{id}/alerts/{alert_id}/
      def get_incident_alert(id, alert_id)
      end

      # List log entries for the specified incident.
      # /incidents/{id}/log_entries
      def get_incidents_log_entries(id)
      end

      # List existing notes for the specified incident.
      # /incidents/{id}/notes
      def get_incidents_notes(id)
      end

      # # Acknowledge, resolve, escalate or reassign one or more incidents.
      # # /incidents
      # def put_incidents()
      # end

      # # Create an incident synchronously without a corresponding event from a monitoring service.
      # # /incidents
      # def post_incidents()
      # end

      # # Merge a list of source incidents into this incident.
      # # /incidents/{id}/merge
      # def merge_incidents()
      # end



      # # Acknowledge, resolve, escalate or reassign an incident.
      # # /incidents/{id}
      # def put_incident(id)
      # end



      # # Resolve multiple alerts or associate them with different incidents.
      # # /incidents/{id}/alerts
      # def update_alerts()
      # end



      # # Resolve an alert or associate an alert with a new parent incident.
      # # /incidents/{id}/alerts/{alert_id}/
      # def put_incidents(id, alert_id)
      # end



      # # Create a new note for the specified incident.
      # # /incidents/{id}/notes
      # def post_incidents_notes(id)
      # end

      # # Snooze an incident.
      # # /incidents/{id}/snooze
      # def snooze_incidents(id)
      # end      
    end
  end
end