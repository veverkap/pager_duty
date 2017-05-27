module PagerDuty
  class Client
    # Module encompassing interactions with the escalation policies API endpoint
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Escalation_Policies
    module EscalationPolicies
      # List escalation policies  
      # @param  options [Sawyer::Resource] A customizable set of options.
      # @option options [String]        :query Filters the results, showing only the escalation policies whose names contain the query.
      # @option options [Array<string>] :user_ids Filters the results, showing only escalation policies on which any of the users is a target.
      # @option options [Array<string>] :team_ids An array of team IDs. Only results related to these teams will be returned. Account must have the teams ability to use this parameter.
      # @option options [Array<string>] :include Array of additional details to include (One or more of <tt>:services</tt>, <tt>:teams</tt>, <tt>:targets</tt>)
      # @option options [String]        :sort_by ("name") Sort the list by '<tt>name</tt>', '<tt>name:asc</tt>' or '<tt>name:desc</tt>'
      # 
      # @return [Array<Sawyer::Resource>] An array of hashes representing escalation policies
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Escalation_Policies/get_escalation_policies
      def escalation_policies(options = {})
        user_ids = options.fetch(:user_ids, [])
        team_ids = options.fetch(:team_ids, [])
        query_params = Hash.new
        query_params["query"]      = options[:query] if options[:query]
        query_params["user_ids[]"] = user_ids.join(",") if user_ids.length > 0
        query_params["team_ids[]"] = team_ids.join(",") if team_ids.length > 0
        query_params["include[]"]  = options[:include] if options[:include]
        query_params["sort_by"]    = options[:sort_by] if options[:sort_by]
        
        response = get "/escalation_policies", options.merge({query: query_params})
        response[:escalation_policies]
      end
      alias :list_escalation_policies :escalation_policies

      # 
      # Gets escalation policy by id
      # @param id [String] Unique identifier
      # @param options [Sawyer::Resource] A customizable set of options.
      # 
      # @return [Sawyer::Resource] Represents escalation policy
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Escalation_Policies/get_escalation_policies_id
      def escalation_policy(id, options = {})
        response = get("/escalation_policies/#{id}", options)
        response[:escalation_policy]
      end
      alias :get_escalation_policy :escalation_policy

      # 
      # Remove an existing escalation policy
      # @param id [String] PagerDuty identifier for escalation policy
      # 
      # @return [Boolean]
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Escalation_Policies/delete_escalation_policies_id
      def delete_escalation_policy(id)
        boolean_from_response :delete, "/escalation_policies/#{id}"
      end
      alias :delete :delete_escalation_policy

      # 
      # Creates an escalation policy
      # @param name: nil [String] name for policy
      # @param escalation_rules: [] [Array<Sawyer::Resource>] List of escalation rule
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :description ("") description of policy
      # @option options [Integer] :num_loops (0) Number of loops
      # @option options [Array<Sawyer::Resource>] :services ([]) List of services
      # @option options [Array<Sawyer::Resource>] :teams ([]) List of associated teams
      # 
      # @return [Sawyer::Resource] Represents escalation policy
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Escalation_Policies/post_escalation_policies
      def create_escalation_policy(name, escalation_rules, options = {}) 
        params = load_params(name: name, 
                             description: options.fetch(:description, nil),
                             num_loops: options.fetch(:num_loops, nil),
                             escalation_rules: escalation_rules, 
                             services: options.fetch(:services, []),
                             teams: options.fetch(:teams, []))
        if options[:from_email_address]
          params[:headers] ||= {}
          params[:headers][:from] = options[:from_email_address]
        end
        response = post "/escalation_policies", options.merge(params)
        response[:escalation_policy]
      end
      alias :create :create_escalation_policy

      # 
      # Update an escalation policy
      # @param id [String] PagerDuty ID
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [String] :name Name for policy
      # @option options [String] :description Description of policy
      # @option options [Integer] :num_loops Number of loops
      # @option options [Array<Sawyer::Resource>] :escalation_rules List of escalation rules
      # @option options [Array<Sawyer::Resource>] :services List of services
      # @option options [Array<Sawyer::Resource>] :teams List of associated teams      
      # 
      # @return [Sawyer::Resource] Represents escalation policy
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Escalation_Policies/put_escalation_policies_id
      def update_escalation_policy(id, options = {}) 
        policy = {}
        policy[:type]             = "escalation_policy"
        policy[:name]             = options[:name] if options[:name]
        policy[:description]      = options[:description] if options[:description]
        policy[:num_loops]        = options[:num_loops] if options[:num_loops]
        policy[:escalation_rules] = options[:escalation_rules] if options[:escalation_rules]
        policy[:services]         = options[:services] if options[:services]
        policy[:teams]            = options[:teams] if options[:teams]

        params = { escalation_policy: policy }
        response = put "/escalation_policies/#{id}", options.merge(params)   
        response[:escalation_policy]
      end

      private

      def load_params(name: nil, description: nil, num_loops: nil, repeat_enabled: false, escalation_rules: [], services: [], teams: []) 
        {
          escalation_policy: {
            type: "escalation_policy",
            name: name,
            escalation_rules: escalation_rules.map { |rule| 
              {
                escalation_delay_in_minutes: rule[:escalation_delay_in_minutes].to_i,
                targets: rule.fetch(:targets, Hash.new()).map { |target| 
                  {
                    id: target[:id], 
                    type: target[:type]
                  }
                }
              } 
            },
            repeat_enabled: repeat_enabled,
            services: services.map { |service|
              {
                id: service[:id],
                type: service[:type]
              }
            },
            num_loops: num_loops.to_i,
            teams: teams.map { |team|  
              {
                id: team[:id],
                type: "team"
              }
            },
            description: description.to_s,
        }}  
      end
    end
  end
end