require "test_helper"
require "pp"

module PagerDuty
  describe Client::LogEntries do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/log_entries" do
      it "returns log_entries for account" do
        VCR.use_cassette("log_entries/index/no_query") do
          log_entries = @client.log_entries
          assert_equal 100, log_entries.count
        end
      end

      it "returns log_entries for account with time_zone" do
        VCR.use_cassette("log_entries/index/time_zone") do
          log_entries = @client.log_entries(time_zone: "EST")
          assert_equal 100, log_entries.count
          assert_equal "2017-05-26 18:40:59 -0500", log_entries.first[:created_at].to_s
        end
      end           
    end

    describe "/log_entries GET" do
      it "returns log_entry for account" do
        VCR.use_cassette("log_entries/log_entry") do
          log_entry = @client.log_entry("R3S5ZGDVULY5D2QJ50QBJXAHS4")
          assert_equal "R3S5ZGDVULY5D2QJ50QBJXAHS4", log_entry[:id]
          assert_equal "2017-05-26 23:40:59 UTC", log_entry[:created_at].to_s
        end
      end   

      it "returns log_entry for account EST" do
        VCR.use_cassette("log_entries/log_entry.EST") do
          log_entry = @client.log_entry("R3S5ZGDVULY5D2QJ50QBJXAHS4", time_zone: "EST")
          assert_equal "R3S5ZGDVULY5D2QJ50QBJXAHS4", log_entry[:id]
          assert_equal "2017-05-26 18:40:59 -0500", log_entry[:created_at].to_s
        end
      end            
    end         
  end
end