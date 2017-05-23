require 'test_helper'
require "pp"
class PagerDutyTest < Minitest::Test
  WebMock.disable_net_connect!(:allow => 'coveralls.io')
  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end

  def test_that_it_gets_permission_errors
    VCR.use_cassette("unauthorized_nil_token") do
      @client = PagerDuty::Client.new(api_token: nil)
      assert_raises(PagerDuty::Unauthorized) do
        @client.abilities
      end
    end
  end  
end
