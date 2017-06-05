require "test_helper"
require "pp"

module PagerDuty
  describe Client::Services do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    # describe "/services" do
    #   it "returns services for account" do
    #     VCR.use_cassette("services/index/no_query") do
    #       services = @client.services
    #       assert_equal 2, services.count
    #       assert_equal "2017-05-10 19:34:42 -0400", services.first[:created_at].to_s
    #     end
    #   end

    #   it "returns services for account with time_zone" do
    #     VCR.use_cassette("services/index/time_zone") do
    #       services = @client.services(time_zone: "UTC")
    #       assert_equal 2, services.count
    #       assert_equal "2017-05-10 23:34:42 UTC", services.first[:created_at].to_s
    #     end
    #   end    

    #   it "returns services for account with query" do
    #     VCR.use_cassette("services/index/query_api") do
    #       services = @client.services(query: "api")
    #       assert_equal 1, services.count
    #       assert_equal "2017-05-10 19:34:42 -0400", services.first[:created_at].to_s
    #     end
    #   end                    
    # end  

    # describe "/service" do
    #   it "returns service for account" do
    #     VCR.use_cassette("services/get/no_query") do
    #       service = @client.service("P7WQ2DJ")
    #       assert_equal "2017-05-10 19:34:42 -0400", service[:created_at].to_s
    #     end
    #   end

    #   it "returns service for account" do
    #     VCR.use_cassette("services/get/include_teams") do
    #       service = @client.service("P7WQ2DJ", include: ["teams"])
    #       assert_equal "2017-05-10 19:34:42 -0400", service[:created_at].to_s
    #     end
    #   end
    # end   

    describe "/services POST" do
      it "creates services for account" do
        VCR.use_cassette("services/create/default") do
          @client.create_service({
            name: "TEST THE THING", 
            type: "schedule",
            time_zone: "America/New_York",
            description: "TEST",
            schedule_layers: [
            {
              start: "2017-05-30 17:28:25 UTC",
              end: "2017-06-09 17:28:25 UTC",
              rotation_virtual_start: "2017-05-30 17:28:25 UTC",
              rotation_turn_length_seconds: 604800,
              users: [
                {
                  user: {
                    id: "PDU9IB6",
                    type: "user"
                  }
                }
              ]
            }],
            escalation_policy: {
              id: "P1N7VS5",
              type: "escalation_policy"
            }
          })

        end
      end                     
    end  

  end
end