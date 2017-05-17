require 'test_helper'

class PagerDutyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PagerDuty::VERSION
  end
end
