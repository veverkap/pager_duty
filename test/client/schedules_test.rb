require "test_helper"
require "pp"

module PagerDuty
  describe Client::Schedules do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/schedules" do
      it "returns schedules for account" do
        VCR.use_cassette("schedules/index/query") do
          schedules = @client.schedules
          assert_equal 2, schedules.count
        end
      end

      it "returns schedules for account with query" do
        VCR.use_cassette("on_calls/index/query_query") do
          schedules = @client.schedules(query: "New")
          assert_equal 1, schedules.count
        end
      end
    end   

    describe "/schedules GET" do
      it "returns schedules for id" do
        VCR.use_cassette("schedules/get/P99HSGO") do
          schedule = @client.schedule("P99HSGO")
          assert_equal "2017-05-30T10:14:05-04:00", schedule[:schedule_layers].first[:start].to_s
        end
      end

      it "returns schedules for id in UTC" do
        VCR.use_cassette("schedules/get/P99HSGO.utc") do
          schedule = @client.schedule("P99HSGO", time_zone: "UTC")
          assert_equal "2017-05-30T14:14:05Z", schedule[:schedule_layers].first[:start].to_s
        end
      end      
    end 

    describe "/schedules/overrides" do
      it "returns schedules for account" do
        VCR.use_cassette("schedules/overrides/query") do
          since = Time.parse("2017-05-10 23:48:27 UTC")
          until_time = Time.parse("2017-06-28 00:53:13 UTC")
          overrides = @client.schedule_overrides("P99HSGO", since: since, until: until_time)
          assert_equal 1, overrides.count
          pp overrides.first
        end
      end
    end            
  
    describe "/schedules/overrides POST" do
      it "creates override for account" do
        VCR.use_cassette("schedules/overrides/create") do
          since = Time.parse("2017-05-30 23:48:27 UTC")
          until_time = Time.parse("2017-06-02 00:53:13 UTC")
          override = @client.create_schedule_override("P99HSGO", start: since, end: until_time, user_id: "PGJLPE9")
          assert_equal "2017-05-30T23:48:27Z", override[:start].to_s
          assert_equal "2017-06-02T00:53:13Z", override[:end].to_s
        end
      end
    end   
  
    describe "/schedules/on_calls" do
      it "returns on_calls schedules for account" do
        VCR.use_cassette("schedules/overrides/users") do
          since = Time.parse("2017-05-10 23:48:27 UTC")
          until_time = Time.parse("2017-06-28 00:53:13 UTC")
          users = @client.on_call_users("P99HSGO", since: since, until: until_time)
          assert_equal 4, users.count
        end
      end
    end  

    describe "/schedules/overrides DELETE" do
      it "deletes override for account" do
        VCR.use_cassette("schedules/overrides/delete") do
          assert @client.delete_schedule_override("P99HSGO", "Q0KU8C9IYGLCQT")
        end
      end
    end   
   

    # describe "/schedules POST" do
    #   it "creates schedule" do
    #     VCR.use_cassette("schedules/post", record: :all) do
    #       start = Time.now.utc
    #       finish = Time.now.utc + 864000
    #       schedule = @client.create_schedule(name: "Test item",
    #                                          time_zone: "America/New_York",
    #                                          description: "Test item",
    #                                          schedule_layers: [
    #                                           {
    #                                             start: start.iso8601,
    #                                             end: finish.iso8601,
    #                                             rotation_virtual_start: start.iso8601,
    #                                             rotation_turn_length_seconds: 86400,
    #                                             users: [{
    #                                               id: "PDU9IB6", 
    #                                               type: "user"
    #                                             }]
    #                                           }
    #                                           ],
    #                                           restrictions: [{
    #                                             type: "daily_restriction",
    #                                             start_time_of_day: "08:00:00",
    #                                             duration_seconds: 32400
    #                                             }])
    #     end
    #   end   
    # end               

    # describe "/schedules PREVIEW" do
    #   it "previews schedule" do
    #     VCR.use_cassette("schedules/previews", record: :all) do
    #       start = Time.now.utc
    #       finish = Time.now.utc + 864000
    #       schedule = @client.preview_schedule(name: "Test item",
    #                                          time_zone: "America/New_York",
    #                                          description: "Test item",
    #                                          schedule_layers: [
    #                                           {
    #                                             start: start.iso8601,
    #                                             end: finish.iso8601,
    #                                             rotation_virtual_start: start.iso8601,
    #                                             rotation_turn_length_seconds: 86400,
    #                                             users: [{
    #                                               id: "PDU9IB6", 
    #                                               type: "user"
    #                                             }]
    #                                           }
    #                                           ],
    #                                           restrictions: [{
    #                                             type: "daily_restriction",
    #                                             start_time_of_day: "08:00:00",
    #                                             duration_seconds: 32400
    #                                             }])
    #     end
    #   end   
    # end  

    # describe "/schedules UPDATE" do
    #   it "updates schedule" do
    #     VCR.use_cassette("schedules/updates", record: :all) do
    #       start = Time.now.utc
    #       finish = Time.now.utc + 864000
    #       schedule = @client.update_schedule("P99HSGO", name: "Test item")
    #     end
    #   end   
    # end    
  end
end

