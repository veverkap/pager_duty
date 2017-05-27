require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "vcr"
require "webmock"
require 'pager_duty'
require 'minitest/autorun'

WebMock.disable_net_connect!
VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

def test_api_token
  ENV.fetch 'TEST_API_TOKEN', 'x' * 40
end
