require "time"
module PagerDuty
  class Client
    # Methods for the MaintenanceWindows API
    #
    # A maintenance window is used to temporarily disable one or more services for a set period of time.
    #
    # No incidents will be triggered and no notifications will be received while a service is disabled by a maintenance window.
    #
    # Maintenance windows are specified to start at a certain time and end after they have begun.
    #
    # Once started, a maintenance window cannot be deleted; it can only be ended immediately to re-enable the service.
    #
    # Read more about maintenance windows in the PagerDuty Knowledge Base 
    # @see https://support.pagerduty.com/hc/en-us/articles/202830350-Putting-a-service-in-maintenance-mode
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Maintenance_windows
    module MaintenanceWindows
      # List existing maintenance windows, optionally filtered by service and/or team, or whether they are from the past, present or future.
      # @param  options [Sawyer::Resource] A customizable set of options.
      # @option options [String]          :query Filters the results, showing only the maintenance windows whose descriptions contain the query.
      # @option options [Array<string>]   :service_ids An array of service IDs. Only results related to these services will be returned.
      # @option options [Array<string>]   :team_ids An array of team IDs. Only results related to these teams will be returned. Account must have the teams ability to use this parameter.
      # @option options [Array<string>]   :include Array of additional details to include (One or more of <tt>:services</tt>, <tt>:teams</tt>, <tt>:users</tt>)
      # @option options [String]        :filter Only return maintenance windows in a given state. (One of <tt>:past</tt>, <tt>:future</tt>, <tt>:ongoing</tt>, <tt>:open</tt> or <tt>:all</tt>).
      # 
      # @return [Array<Sawyer::Resource>] An array of hashes representing maintenance windows
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Maintenance_Windows/get_maintenance_windows
      def maintenance_windows(options = {})
        service_ids = options.fetch(:service_ids, [])
        team_ids    = options.fetch(:team_ids, [])
        
        query_params = Hash.new
        query_params["query"]         = options[:query] if options[:query]
        query_params["team_ids[]"]    = team_ids.join(",") if team_ids.length > 0
        query_params["service_ids[]"] = service_ids.join(",") if service_ids.length > 0
        query_params["include[]"]     = options[:include] if options[:include]
        query_params["filter"]        = options[:filter] if options[:filter]

        response = get "/maintenance_windows", options.merge({query: query_params})
        response[:maintenance_windows]
      end
      alias :list_maintenance_windows :maintenance_windows

      # Get an existing maintenance window.
      # @param  id      [String]           ID for maintenance window
      # @param  options [Sawyer::Resource] A customizable set of options.
      # @option options [Array<string>]   :include Array of additional details to include (One or more of <tt>:services</tt>, <tt>:teams</tt>, <tt>:users</tt>)
      # 
      # @return [Sawyer::Resource] An hash representing maintenance window
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Maintenance_Windows/get_maintenance_windows_id
      def maintenance_window(id, options = {})
        query_params = Hash.new
        query_params["include[]"]     = options[:include] if options[:include]

        response = get "/maintenance_windows/#{id}", options.merge({query: query_params})
        response[:maintenance_window]
      end 
      alias :get_maintenance_window :maintenance_window     

      # # Create a new maintenance window for the specified services. No new incidents will be created for a service that is in maintenance.
      # @param from_email_address [String] User creating maintenance window
      # @param start_time         [String] Start time of maintenance window in ISO8601 format
      # @param end_time           [String] End time of maintenance window in ISO8601 format
      # @param description        [String] Description of maintenace window
      # @param service_id         [String] Service referenced in maintenance window
      # @param  options [Sawyer::Resource] A customizable set of options.
      # 
      # @return [Sawyer::Resource] An hash representing maintenance window
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Maintenance_Windows/post_maintenance_windows
      def create_maintenance_window(from_email_address, start_time, end_time, description, service_id, options = {})
        if from_email_address
          options[:headers] ||= {}
          options[:headers][:from] = from_email_address
        end 

        params = { 
          maintenance_window: {
            type: "maintenance_window",
            start_time: start_time,
            end_time:  end_time,
            description: description,
            services: [
              {
                id: service_id,
                type: "service_reference"
              }
            ]
          }
        }
        response = post "/maintenance_windows", options.merge(params)
        response[:maintenance_window]        
      end

      # # Delete an existing maintenance window if it's in the future, or end it if it's currently on-going. If the maintenance window has already ended it cannot be deleted.
      # @param id [String] PagerDuty identifier for maintenance window
      # 
      # @return [Boolean]
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Maintenance_Windows/delete_maintenance_windows_id
      def delete_maintenance_window(id, options = {})
        boolean_from_response :delete, "/maintenance_windows/#{id}", options
      end

      # # Update an existing maintenance window.
      # # /maintenance_windows/{id}
      # def put_maintenance_windows/{id}({"name"=>"maintenance_window", "in"=>"body", "description"=>"The maintenance window to be updated.", "schema"=>{"type"=>"object", "properties"=>{"maintenance_window"=>{"$ref"=>"#/definitions/MaintenanceWindow"}}, "required"=>["maintenance_window"]}}, {"$ref"=>"#/parameters/id"}, id)
      # end

      # # Update an existing maintenance window.
      # @param id                 [String] PagerDuty id for maintenance window
      # @param start_time         [String] Start time of maintenance window in ISO8601 format
      # @param end_time           [String] End time of maintenance window in ISO8601 format
      # @param description        [String] Description of maintenace window
      # @param service_id         [String] Service referenced in maintenance window
      # @param options [Sawyer::Resource] A customizable set of options.
      # 
      # @return [Sawyer::Resource] An hash representing maintenance window
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Maintenance_Windows/put_maintenance_windows_id
      def update_maintenance_window(id, start_time, end_time, description, service_id, options = {})
        params = { 
          maintenance_window: {
            type: "maintenance_window",
            start_time: start_time,
            end_time:  end_time,
            description: description,
            services: [
              {
                id: service_id,
                type: "service_reference"
              }
            ]
          }
        }
        response = put "/maintenance_windows/#{id}", options.merge(params)
        response[:maintenance_window]        
      end
    end
  end
end