module PagerDuty
  class Client
    # A PagerDuty service represents something you monitor (like a web service, email service, or database service). It is a container for related incidents that associates them with escalation policies.
    #
    # A service is the focal point for incident management; services specify the configuration for the behavior of incidents triggered on them. This behavior includes specifying urgency and performing automated actions based on time of day, incident duration, and other factors.
    #
    # Integrations
    #
    # An integration is an endpoint (like Nagios, email, or an API call) that generates events, which are normalized and de-duplicated by PagerDuty to create incidents. Integrations feed events into services and provide event management functionality such as filtering and de-duplication.
    #
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Services
    # @see https://support.pagerduty.com/hc/en-us/sections/200550800-Services
    module Services
      # List existing services.
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :query Filters the result, showing only the services whose name or service_key matches the query.
      # @option options [Array<String>] :team_ids An array of team IDs. Only results related to these teams will be returned. Account must have the <tt>`teams`</tt> ability to use this parameter.
      # @option options [String] :time_zone Time zone in which dates in the result will be rendered.
      # @option options [String] :sort_by Used to specify the field you wish to sort the results on.
      # @option options [Array<String>] :include Array of additional details to include. (One or more of <tt>escalation_policies</tt>, <tt>teams</tt>, <tt>integrations</tt>)
      # @return [Array<Sawyer::Resource>] An array of hashes representing services
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Services/get_services
      def services(options = {})
        query_params = Hash.new
        query_params[:query]      = options[:query] if options[:query]
        query_params[:time_zone]  = options[:time_zone] if options[:time_zone]
        query_params[:sort_by]    = options[:sort_by] if options[:sort_by]
        
        team_ids = options.fetch(:team_ids, [])
        query_params["team_ids[]"]    = team_ids.join(",") if team_ids.length > 0
        query_params["include"]       = options[:include] if options[:include]

        response = get "/services", options.merge({query: query_params})
        response[:services]        
      end
      alias :list_services :services

      # Get details about an existing service.
      # @param id [String] Service id
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [Array<String>] :include Array of additional details to include. (One or more of <tt>escalation_policies</tt> or <tt>teams</tt>)
      # @return [Sawyer::Resource] A hash representing service
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Services/get_services_id
      def service(id, options = {})  
        response = get("/services/#{id}", options)
        response[:service]
      end
      alias :get_service :service

      # Create a new service.
      # /services
      def create_service(service = {}, options = {})
        options[:service] = service
        response = post "/services", options
        response[:service]        
      end



      # Delete an existing service. Once the service is deleted, it will not be accessible from the web UI and new incidents won't be able to be created for this service.
      # /services/{id}

      # Update an existing service.
      # /services/{id}



      # Create a new integration belonging to a service.
      # /services/{id}/integrations

      # Update an integration belonging to a service.
      # /services/{id}/integrations/{integration_id}


      # Get details about an integration belonging to a service.
      # /services/{id}/integrations/{integration_id}


    end
  end
end