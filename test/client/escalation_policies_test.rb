require "test_helper"
require "pp"

module PagerDuty
  describe Client::EscalationPolicies do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/escalation_policies" do
      it "returns escalation_policies for account" do
        VCR.use_cassette("escalation_policies/index.no_query") do
          policies = @client.escalation_policies()
          assert_equal 5, policies.count
          assert_equal ["Default", "Devs Only", "Engineering Escalation Policy", "Policy Name", "TEST CREATE"], policies.map { |policy| policy[:name] }
        end
      end

      it "returns escalation_policies for account filtered by query" do
        VCR.use_cassette("escalation_policies/index.query") do
          policies = @client.escalation_policies(query: "Policy")
          assert_equal 2, policies.count
        end
      end 

      it "returns escalation_policies for account sorted by name asc" do
        VCR.use_cassette("escalation_policies/index.name_asc") do
          policies = @client.escalation_policies(sort_by: "name:asc")
          assert_equal 5, policies.count
          assert_equal ["Default", "Devs Only", "Engineering Escalation Policy", "Policy Name", "TEST CREATE"], policies.map { |policy| policy[:name] }
        end
      end   

      it "returns escalation_policies for account sorted by name desc" do
        VCR.use_cassette("escalation_policies/index.name_desc") do
          policies = @client.escalation_policies(sort_by: "name:desc")
          assert_equal 5, policies.count
          assert_equal ["TEST CREATE", "Policy Name", "Engineering Escalation Policy", "Devs Only", "Default"], policies.map { |policy| policy[:name] }
        end
      end

      it "returns escalation_policies for account including services" do
        VCR.use_cassette("escalation_policies/index.include_services") do
          policies = @client.escalation_policies(include: ["services"])
          assert_equal 5, policies.count
          assert_equal ["P7WQ2DJ"], policies.map { |policy| 
            policy[:services].first[:id] unless policy[:services] == []
          }.compact
        end
      end   

      it "returns escalation_policies for account including services and teams" do
        VCR.use_cassette("escalation_policies/index.include_services_teams") do
          policies = @client.escalation_policies(include: ["services", "teams"])
          assert_equal 5, policies.count
          assert_equal ["P7WQ2DJ"], policies.map { |policy| 
            policy[:services].first[:id] unless policy[:services] == []
          }.compact

          assert_equal ["P7XILUG"], policies.map { |policy| 
            policy[:teams].first[:id] unless policy[:teams] == []
          }.compact.uniq
        end
      end    

      it "returns escalation_policies for account including services teams and targets" do
        VCR.use_cassette("escalation_policies/index.include_services_teams_targets") do
          policies = @client.escalation_policies(include: ["services", "teams", "targets"])
          assert_equal 5, policies.count
          assert_equal ["P7WQ2DJ"], policies.map { |policy| 
            policy[:services].first[:id] unless policy[:services] == []
          }.compact

          assert_equal ["P7XILUG"], policies.map { |policy| 
            policy[:teams].first[:id] unless policy[:teams] == []
          }.compact.uniq
        end
      end  

      it "returns escalation_policies for account filtered by user_id when user has nothing" do
        VCR.use_cassette("escalation_policies/index.user_id_nothing") do
          policies = @client.escalation_policies(user_ids: ["PDU9IB6"])
          assert_equal 0, policies.count
        end
      end  

      it "returns escalation_policies for account filtered by user_id when user has one" do
        VCR.use_cassette("escalation_policies/index.user_id_has_one") do
          policies = @client.escalation_policies(user_ids: ["PGJLPE9"])
          assert_equal 1, policies.count
        end
      end 

      it "returns escalation_policies for account filtered by user_id when user has five" do
        VCR.use_cassette("escalation_policies/index.user_id_has_five") do
          policies = @client.escalation_policies(user_ids: ["PRTFS0C"])
          assert_equal 5, policies.count
        end
      end  

      it "returns escalation_policies for account filtered by user_id when user has two" do
        VCR.use_cassette("escalation_policies/index.user_id_has_four") do
          policies = @client.escalation_policies(user_ids: ["PW21NA6"])
          assert_equal 4, policies.count
        end
      end   

      it "returns escalation_policies for account filtered by multiple user_id" do
        VCR.use_cassette("escalation_policies/index.multiple_user_ids") do
          policies = @client.escalation_policies(user_ids: ["PW21NA6", "PRTFS0C"])
          assert_equal 4, policies.count
        end
      end   

      it "returns escalation_policies for account filtered by team ids" do
        VCR.use_cassette("escalation_policies/index.team_ids") do
          policies = @client.escalation_policies(team_ids: ["P7XILUG"])
          assert_equal 2, policies.count
        end
      end   
    end

    describe "/escalation_policies GET" do
      it "will get an escalation_policies by id" do
        VCR.use_cassette("escalation_policies/get_by_id") do
          policy = @client.escalation_policy("P1N7VS5")
          assert_equal "P1N7VS5", policy[:id] 
          assert_equal "Default", policy[:name]
        end
      end

      it "won't get a deleted escalation_policies by id" do
        VCR.use_cassette("escalation_policies/get_deleted") do
          assert_raises(PagerDuty::NotFound) do
            @client.escalation_policy("P8LF8XV")
          end
        end
      end      
    end

    describe "/escalation_policies DELETE" do
      it "will not delete an escalation_policy with readonly key" do
        VCR.use_cassette("escalation_policies/delete.P7N334Z") do
          assert_raises(PagerDuty::Forbidden) do
            @client.delete_escalation_policy("P2JEHJE")
          end
        end
      end      

      it "will delete an addon with an id" do
        VCR.use_cassette("escalation_policies/delete.P09984M.allowed") do
          existing = @client.escalation_policy("P2JEHJE")
          assert @client.delete_escalation_policy("P2JEHJE")
          assert_raises(PagerDuty::NotFound) do
            find_again = @client.escalation_policy("P2JEHJE")
          end
        end
      end
    end   

    describe "/escalation_policies POST" do
      it "will not create an escalation_policy without escalation rules targets" do
        VCR.use_cassette("escalation_policies/create.no_escalation_rule_targets") do
          assert_raises(PagerDuty::BadRequest) do
            @client.create_escalation_policy("TEST", [{escalation_delay_in_minutes: 10}])
          end
        end
      end 

      it "will not create an escalation_policy with read only " do
        VCR.use_cassette("escalation_policies/create.does_not_work") do
          assert_raises(PagerDuty::Forbidden) do
            name = "Generated Policy"
            escalation_rules = [
              {
                escalation_delay_in_minutes: 10,
                targets: [
                  {
                    id: "PQLNQ9T",
                    type: "schedule"
                  }
                ]
              }
            ]
            services = [
            {
              id: "P7WQ2DJ",
              type: "service"
            }]
            teams = [
            {
              id: "P7XILUG",
              type: "team"
            }]

            policy = @client.create_escalation_policy(name,
                                                         escalation_rules,
                                                         repeat_enabled: false,
                                                         services: services,
                                                         num_loops: 0,
                                                         teams: teams,
                                                         description: "Generic Description",
                                                         from_email_address: "user@domain.com")

          end
        end
      end 

      it "will create an escalation_policy with escalation rules targets" do
        VCR.use_cassette("escalation_policies/create.works") do
          name = "Generated Policy"
          escalation_rules = [
            {
              escalation_delay_in_minutes: 10,
              targets: [
                {
                  id: "PQLNQ9T",
                  type: "schedule"
                }
              ]
            }
          ]
          services = [
          {
            id: "P7WQ2DJ",
            type: "service"
          }]
          teams = [
          {
            id: "P7XILUG",
            type: "team"
          }]

          policy = @client.create_escalation_policy(name,
                                                       escalation_rules,
                                                       repeat_enabled: false,
                                                       services: services,
                                                       num_loops: 0,
                                                       teams: teams,
                                                       description: "Generic Description",
                                                       from_email_address: "user@domain.com")
          assert_equal "escalation_policy", policy[:type]
          assert_equal name, policy[:name]
          assert_equal 1, policy[:teams].count
          assert_equal 1, policy[:escalation_rules].count
        end
      end                  
    end

    describe "/escalation_policies PUT" do
      it "will not update an escalation_policy without changing anything" do
        VCR.use_cassette("escalation_policies/update.no_name") do
          existing = @client.escalation_policy("P1N7VS5")
          response = @client.update_escalation_policy("P1N7VS5")

          existing_first = existing[:escalation_rules].first
          response_first = response[:escalation_rules].first
          existing_target = existing_first[:targets].first
          response_target = response_first[:targets].first

          assert_equal existing[:id], "P1N7VS5"
          assert_equal existing[:type], "escalation_policy"
          assert_equal existing[:summary], "Default"
          assert_equal existing[:name], "Default"

          assert_equal existing_first[:id], response_first[:id]
          assert_equal existing_first[:escalation_delay_in_minutes], response_first[:escalation_delay_in_minutes]
          assert_equal existing_target[:id], response_target[:id]
          assert_equal existing_target[:type], response_target[:type]
          assert_equal existing_target[:summary], response_target[:summary]
        end
      end

      it "will update an escalation_policy name" do
        VCR.use_cassette("escalation_policies/update.name_only") do
          existing = @client.escalation_policy("P1N7VS5")
          assert_equal existing[:name], "Default"
          response = @client.update_escalation_policy("P1N7VS5", name: "Default Changed")          
          assert_equal response[:name], "Default Changed"

          existing_first = existing[:escalation_rules].first
          response_first = response[:escalation_rules].first
          existing_target = existing_first[:targets].first
          response_target = response_first[:targets].first

          assert_equal existing[:summary], "Default"
          assert_equal existing[:id], "P1N7VS5"
          assert_equal existing[:type], "escalation_policy"

          assert_equal existing_first[:id], response_first[:id]
          assert_equal existing_first[:escalation_delay_in_minutes], response_first[:escalation_delay_in_minutes]
          assert_equal existing_target[:id], response_target[:id]
          assert_equal existing_target[:type], response_target[:type]
          assert_equal existing_target[:summary], response_target[:summary]          
        end
      end  

      it "will update an escalation_policy description" do
        VCR.use_cassette("escalation_policies/update.description_only") do
          existing = @client.escalation_policy("P1N7VS5")
          assert_equal "Summary Value", existing[:description]
          response = @client.update_escalation_policy("P1N7VS5", description: "Description Value")
          assert_equal "Description Value", response[:description]

          existing_first = existing[:escalation_rules].first
          response_first = response[:escalation_rules].first
          existing_target = existing_first[:targets].first
          response_target = response_first[:targets].first

          assert_equal existing[:id], "P1N7VS5"
          assert_equal existing[:type], "escalation_policy"

          assert_equal existing_first[:id], response_first[:id]
          assert_equal existing_first[:escalation_delay_in_minutes], response_first[:escalation_delay_in_minutes]
          assert_equal existing_target[:id], response_target[:id]
          assert_equal existing_target[:type], response_target[:type]
          assert_equal existing_target[:summary], response_target[:summary]          
        end
      end  

      it "will update an escalation_policy num_loops" do
        VCR.use_cassette("escalation_policies/update.num_loops_only") do
          existing = @client.escalation_policy("P1N7VS5")
          assert_equal 0, existing[:num_loops]
          response = @client.update_escalation_policy("P1N7VS5", num_loops: 5)
          assert_equal 5, response[:num_loops]

          existing_first = existing[:escalation_rules].first
          response_first = response[:escalation_rules].first
          existing_target = existing_first[:targets].first
          response_target = response_first[:targets].first

          assert_equal existing[:id], "P1N7VS5"
          assert_equal existing[:type], "escalation_policy"

          assert_equal existing_first[:id], response_first[:id]
          assert_equal existing_first[:escalation_delay_in_minutes], response_first[:escalation_delay_in_minutes]
          assert_equal existing_target[:id], response_target[:id]
          assert_equal existing_target[:type], response_target[:type]
          assert_equal existing_target[:summary], response_target[:summary]          
        end
      end  

      it "will update an escalation_policy escalation_rules" do
        VCR.use_cassette("escalation_policies/update.escalation_rules_only") do

          escalation_rules = [
            {
              escalation_delay_in_minutes: 20,
              targets: [
                {
                  id: "PQLNQ9T",
                  type: "schedule"
                }
              ]
            }
          ]

          existing = @client.escalation_policy("P1N7VS5")
          response = @client.update_escalation_policy("P1N7VS5", escalation_rules: escalation_rules)

          existing_first = existing[:escalation_rules].first
          response_first = response[:escalation_rules].first
          existing_target = existing_first[:targets].first
          response_target = response_first[:targets].first

          assert_equal existing[:id], "P1N7VS5"
          assert_equal existing[:type], "escalation_policy"

          refute_equal existing_first[:id], response_first[:id]
          assert_equal 20, response_first[:escalation_delay_in_minutes]
          assert_equal existing_target[:id], response_target[:id]
          assert_equal existing_target[:type], response_target[:type]
          assert_equal existing_target[:summary], response_target[:summary]          
        end
      end  

      it "will update an escalation_policy escalation_rules" do
        VCR.use_cassette("escalation_policies/update.escalation_rules_user") do

          escalation_rules = [
            {
              escalation_delay_in_minutes: 20,
              targets: [
                {
                  id: "PDU9IB6",
                  type: "user"
                }
              ]
            }
          ]

          existing = @client.escalation_policy("P1N7VS5")
          response = @client.update_escalation_policy("P1N7VS5", escalation_rules: escalation_rules)

          pp response

          existing_first = existing[:escalation_rules].first
          response_first = response[:escalation_rules].first
          existing_target = existing_first[:targets].first
          response_target = response_first[:targets].first

          assert_equal existing[:id], "P1N7VS5"
          assert_equal existing[:type], "escalation_policy"

          refute_equal existing_first[:id], response_first[:id]
          assert_equal 20, response_first[:escalation_delay_in_minutes]
          assert_equal "PDU9IB6", response_target[:id]
          assert_equal "user_reference", response_target[:type]
        end
      end  

      it "will update an escalation_policy escalation_rules" do
        VCR.use_cassette("escalation_policies/update.teams") do
          teams = [
          {
            id: "P1HE60B",
            type: "team"
          }]

          existing = @client.escalation_policy("P1N7VS5")
          response = @client.update_escalation_policy("P1N7VS5", teams: teams)

          response_team = response[:teams].first

          assert_equal "P1HE60B", response_team[:id]
        end
      end               
    end
  end
end
