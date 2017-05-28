require "test_helper"
require "pp"

module PagerDuty
  describe Client::OnCalls do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/on_calls" do
      it "returns on_calls for account" do
        VCR.use_cassette("on_calls/index/query") do
          on_calls = @client.on_calls
          assert_equal 8, on_calls.count
        end
      end

      it "returns on_calls for account in EST" do
        VCR.use_cassette("on_calls/index/query_since_est") do
          on_calls = @client.on_calls(time_zone: "EST")
          assert_equal 8, on_calls.count
          assert_equal "2017-05-27T20:00:00-05:00", on_calls.last[:start].to_s
        end
      end

      it "returns on_calls for account including users" do
        VCR.use_cassette("on_calls/index/query_include_users") do
          on_calls = @client.on_calls(include: ["users"])
          assert_equal 8, on_calls.count
        end
      end  

      it "returns on_calls for account including users" do
        VCR.use_cassette("on_calls/index/query_include_users_and_schedules") do
          on_calls = @client.on_calls(include: ["users", "schedules"])
          assert_equal 8, on_calls.count
        end
      end    

      it "returns on_calls for account since/until" do
        VCR.use_cassette("on_calls/index/query_since_until") do
          since = Time.parse("2017-05-28 23:48:27 UTC")
          until_time = Time.parse("2017-06-04 00:53:13 UTC")          
          on_calls = @client.on_calls(since: since, until: until_time)
          assert_equal 8, on_calls.count
        end
      end   

      it "returns on_calls for account earliest" do
        VCR.use_cassette("on_calls/index/query_earliest") do
          on_calls = @client.on_calls(earliest: true)
          assert_equal 8, on_calls.count
        end
      end   
    end       
  end
end