require "time"
module PagerDuty
  class Client
    # An on-call schedule determines the time periods that users are on call. Only on-call users are eligible to receive notifications from incidents.
    #
    # The details of the on-call schedule specify which single user is on call for that schedule at any given point in time. An on-call schedule consists of one or more schedule layers that rotate a group of users through the same shift at a set interval.
    #
    # Restrictions on each schedule layer limit on-call responsibility for that layer to certain times of the day or week. The period of time during which a user is present on a schedule layer is called a schedule layer entry.
    #
    # The ordered composition of schedule layers, combined with any schedule layer entries from the override layer, known as overrides, results in the final schedule layer. The final schedule layer represents the computed set of schedule layer entries that put users on call for the schedule, and cannot be modified directly.
    #
    # Schedules are used by escalation policies as an escalation target for a given escalation rule.
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules
    # @see https://support.pagerduty.com/hc/en-us/sections/200550790-On-Call-Schedules
    module Schedules
      # List the on-call schedules.
      # /schedules
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :query Filters the result, showing only the schedules whose name matches the query.
      # 
      # @return [Array<Sawyer::Resource>] An array of hashes representing schedules
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/get_schedules
      def schedules(options = {})
        query_params = Hash.new
        query_params[:query] = options[:query] if options[:query]
        
        response = get "/schedules", options.merge({query: query_params})
        response[:schedules]
      end
      alias :list_schedules :schedules

      # Show detailed information about a schedule, including entries for each layer and sub-schedule.
      # @param id [String] Schedule ID
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :since The start of the date range over which you want to search ISO8601 format
      # @option options [String] :until The end of the date range over which you want to search ISO8601 format
      # @option options [String] :time_zone Time zone in which dates in the result will be rendered.      
      # 
      # @return [Sawyer::Resource] A hash representing schedule
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/get_schedules_id
      def schedule(id, options = {})
        query_params = Hash.new
        query_params[:since]      = options[:since].utc.iso8601 if options[:since]
        query_params[:until]      = options[:until].utc.iso8601 if options[:until]
        query_params[:time_zone]  = options[:time_zone] if options[:time_zone]
        
        response = get "/schedules/#{id}", options.merge({query: query_params})
        response[:schedule]
      end      

      # 
      # Delete an on-call schedule.
      # @param id [String] schedule ID
      # 
      # @return [Boolean]
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/delete_schedules_id
      def delete_schedule(id)
        boolean_from_response :delete, "/schedules/#{id}"
      end

      # Create an override for a specific user covering the specified time range. If you create an override on top of an existing one, the last created override will have priority.
      # @param id [String] Schedule ID
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options start [String] When to start
      # @option options end [String] When to end
      # @option options user_id [String] Associated user
      # 
      # @return [Sawyer::Resource] A hash representing override
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/post_schedules_id_overrides
      def create_schedule_override(id, options = {})
        params = {
          override: {
            start: options[:start],
            end: options[:end],
            user: {
              id: options[:user_id],
              type: "user"
            }
          }
        }        
        response = post "/schedules/#{id}/overrides", options.merge(params)
        response[:override]
      end 


      # List overrides for a given time range.
      # @param id [String] Schedule ID
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :since The start of the date range over which you want to search ISO8601 format
      # @option options [String] :until The end of the date range over which you want to search ISO8601 format
      # @option options [String] :time_zone Time zone in which dates in the result will be rendered.      
      # 
      # @return [Sawyer::Resource] A hash representing schedule
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/get_schedules_id_overrides
      def schedule_overrides(id, options = {})
        query_params = Hash.new
        query_params[:since]    = options[:since].utc.iso8601 if options[:since]
        query_params[:until]    = options[:until].utc.iso8601 if options[:until]        
        query_params[:overflow] = options[:overflow] if options[:overflow]
        query_params[:editable] = options[:editable] if options[:editable]
        
        response = get "/schedules/#{id}/overrides", options.merge({query: query_params})
        response[:overrides]
      end 


      # List all of the users on call in a given schedule for a given time range.
      # @param id [String] Schedule ID
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :since The start of the date range over which you want to search ISO8601 format
      # @option options [String] :until The end of the date range over which you want to search ISO8601 format
      # 
      # @return [Sawyer::Resource] A hash representing users
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/get_schedules_id_users
      def on_call_users(id, options = {})
        query_params = Hash.new
        query_params[:since]    = options[:since].utc.iso8601 if options[:since]
        query_params[:until]    = options[:until].utc.iso8601 if options[:until]        
        
        response = get "/schedules/#{id}/users", options.merge({query: query_params})
        response[:users]
      end       


      # 
      # Delete an on-call schedule override
      # @param schedule_id [String] schedule ID
      # @param override_id [String] override ID
      # 
      # @return [Boolean]
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/delete_schedules_id_overrides_override_id
      def delete_schedule_override(schedule_id, override_id)
        boolean_from_response :delete, "/schedules/#{schedule_id}/overrides/#{override_id}"
      end      

      #################################################################################################
      # There is a bug in the API and these functions always give an error that the User array is empty
      #################################################################################################

      # Create a new on-call schedule.
      # TODO: MAKE THIS WORK
      #
      # Any on-call schedule entries that pass the date range bounds will be
      # truncated at the bounds, unless the parameter <tt>overflow=true</tt> is passed.
      # This parameter defaults to false.
      #
      # For instance, if your schedule is a rotation that changes daily at midnight
      # UTC, and your date range is from <tt>2011-06-01T10:00:00Z</tt> to
      # <tt>2011-06-01T14:00:00Z</tt>:
      #
      # - If you don't pass the <tt>overflow=true</tt> parameter, you will get one
      # schedule entry returned with a start of <tt>2011-06-01T10:00:00Z</tt> and end of
      # <tt>2011-06-01T14:00:00Z</tt>.
      #
      # - If you do pass the <tt>overflow=true</tt> parameter, you will get one schedule
      # entry returned with a start of <tt>2011-06-01T00:00:00Z</tt> and end of
      # <tt>2011-06-02T00:00:00Z</tt>.
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [Boolean] :overflow Any on-call schedule entries that pass the date range bounds will be truncated at the bounds, unless the parameter overflow=true is passed
      # @option options [Hash] :schedule
      #   * :name (String) The name of the schedule (optional)
      #   * :time_zone (String) The time zone of the schedule. (required)
      #   * :description (String) The description of the schedule (optional)
      #   * :schedule_layers (String) A list of schedule layers.
      #     * :start (String) The start time of this layer. (required)
      #     * :end (String) The end time of this layer. If `null`, the layer does not end. (optional)
      #     * :rotation_virtual_start (String) The effective start time of the layer. This can be before the start time of the schedule.
      #     * :rotation_turn_length_seconds (Integer) The duration of each on-call shift in seconds.
      #     * :name (String) The name of the schedule layer. (optional)
      #     * :users (Array<Sawyer::Resource>) The ordered list of users on this layer. The position of the user on the list determines their order in the layer.
      #       * :id (String) Id of user
      #       * :type (String) Always <tt>user</tt>     
      #     * :restrictions (Array<Sawyer::Resource>) An array of restrictions for the layer. A restriction is a limit on which period of the day or week the schedule layer can accept assignments. (optional)
      #       * :type (String) Specify the types of `restriction`. (One of <tt>:daily_restriction</tt> or <tt>:weekly_restriction</tt>)
      #       * :start_time_of_day (String) The start time in HH:mm:ss format.
      #       * :duration_seconds (Integer) The duration of the restriction in seconds.
      #       * :start_day_of_week (Integer) Only required for use with a `weekly_restriction` restriction type. The first day of the weekly rotation schedule as ISO 8601 day (https://en.wikipedia.org/wiki/ISO_week_date) (1 is Monday, etc.)
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/post_schedules
      # @api private
      def create_schedule(options = {})
        params = { query: { overflow: options.fetch(:overflow, false) }}
        params[:schedule] = {
          name: options[:name],
          type: "schedule",
          time_zone: options.fetch(:time_zone, "UTC"),
          description: options[:description],
          schedule_layers: options[:schedule_layers],
          restrictions: options[:restrictions]
        }
        response = post "/schedules", options.merge(params)
        response[:schedule]
      end 

      # Preview what an on-call schedule would look like without saving it.
      # TODO: MAKE THIS WORK
      #      
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :since The start of the date range over which you want to search ISO8601 format
      # @option options [String] :until The end of the date range over which you want to search ISO8601 format
      # @option options [Boolean] :overflow Any on-call schedule entries that pass the date range bounds will be truncated at the bounds, unless the parameter overflow=true is passed
      # @option options [Hash] :schedule
      #   * :name (String) The name of the schedule (optional)
      #   * :time_zone (String) The time zone of the schedule. (required)
      #   * :description (String) The description of the schedule (optional)
      #   * :schedule_layers (String) A list of schedule layers.
      #     * :start (String) The start time of this layer. (required)
      #     * :end (String) The end time of this layer. If `null`, the layer does not end. (optional)
      #     * :rotation_virtual_start (String) The effective start time of the layer. This can be before the start time of the schedule.
      #     * :rotation_turn_length_seconds (Integer) The duration of each on-call shift in seconds.
      #     * :name (String) The name of the schedule layer. (optional)
      #     * :users (Array<Sawyer::Resource>) The ordered list of users on this layer. The position of the user on the list determines their order in the layer.
      #       * :id (String) Id of user
      #     * :restrictions (Array<Sawyer::Resource>) An array of restrictions for the layer. A restriction is a limit on which period of the day or week the schedule layer can accept assignments. (optional)
      #       * :type (String) Specify the types of `restriction`. (One of <tt>:daily_restriction</tt> or <tt>:weekly_restriction</tt>)
      #       * :start_time_of_day (String) The start time in HH:mm:ss format.
      #       * :duration_seconds (Integer) The duration of the restriction in seconds.
      #       * :start_day_of_week (Integer) Only required for use with a `weekly_restriction` restriction type. The first day of the weekly rotation schedule as ISO 8601 day (https://en.wikipedia.org/wiki/ISO_week_date) (1 is Monday, etc.)
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/post_schedules_preview
      # @api private
      def preview_schedule(options = {})
        query_params = Hash.new
        query_params[:since]    = options[:since].utc.iso8601 if options[:since]
        query_params[:until]    = options[:until].utc.iso8601 if options[:until]
        query_params[:overflow] = options.fetch(:overflow, false)

        schedule = {
          name: options[:name],
          type: "schedule",
          time_zone: options.fetch(:time_zone, "UTC"),
          description: options[:description],
          schedule_layers: options[:schedule_layers],
          restrictions: options[:restrictions]
        }

        params = { schedule: schedule }
        response = post "/schedules/preview", options.merge({query: query_params, body: params})
        response[:schedule]
      end   

      # Update an existing on-call schedule.
      # TODO: MAKE THIS WORK
      #      
      # @param id [String] Id for the resource
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [Boolean] :overflow Any on-call schedule entries that pass the date range bounds will be truncated at the bounds, unless the parameter overflow=true is passed
      # @option options [Hash] :schedule
      #   * :name (String) The name of the schedule (optional)
      #   * :time_zone (String) The time zone of the schedule. (required)
      #   * :description (String) The description of the schedule (optional)
      #   * :schedule_layers (String) A list of schedule layers.
      #     * :start (String) The start time of this layer. (required)
      #     * :end (String) The end time of this layer. If `null`, the layer does not end. (optional)
      #     * :rotation_virtual_start (String) The effective start time of the layer. This can be before the start time of the schedule.
      #     * :rotation_turn_length_seconds (Integer) The duration of each on-call shift in seconds.
      #     * :name (String) The name of the schedule layer. (optional)
      #     * :users (Array<Sawyer::Resource>) The ordered list of users on this layer. The position of the user on the list determines their order in the layer.
      #       * :id (String) Id of user
      #     * :restrictions (Array<Sawyer::Resource>) An array of restrictions for the layer. A restriction is a limit on which period of the day or week the schedule layer can accept assignments. (optional)
      #       * :type (String) Specify the types of `restriction`. (One of <tt>:daily_restriction</tt> or <tt>:weekly_restriction</tt>)
      #       * :start_time_of_day (String) The start time in HH:mm:ss format.
      #       * :duration_seconds (Integer) The duration of the restriction in seconds.
      #       * :start_day_of_week (Integer) Only required for use with a `weekly_restriction` restriction type. The first day of the weekly rotation schedule as ISO 8601 day (https://en.wikipedia.org/wiki/ISO_week_date) (1 is Monday, etc.)
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Schedules/put_schedules_id
      # @api private      
      def update_schedule(id, options = {})
        query_params = Hash.new
        query_params[:overflow] = options.fetch(:overflow, false)

        schedule = {
          name: options[:name],
          type: "schedule",
          time_zone: options.fetch(:time_zone, "UTC"),
          description: options[:description],
          schedule_layers: options[:schedule_layers],
          restrictions: options[:restrictions]
        }

        options = options.merge({query: query_params, schedule: schedule})
        response = put "/schedules/#{id}", options
        response[:schedule]
      end              
    end
  end
end