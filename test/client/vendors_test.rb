require "test_helper"
require "pp"

module PagerDuty
  describe Client::Vendors do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/vendors" do
      it "returns vendors for account" do
        VCR.use_cassette("vendors/index/no_query") do
          vendors = @client.vendors
          assert_equal 25, vendors.count
        end
      end        
    end

    describe "/vendors GET" do
      it "returns vendor" do
        VCR.use_cassette("vendors/vendor") do
          vendor = @client.vendor("PXPGF42")
          assert_equal "PXPGF42", vendor[:id]
          assert_equal "Apica", vendor[:name]
        end
      end   
    end         
  end
end