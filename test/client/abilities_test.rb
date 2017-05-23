require "test_helper"
require "pp"

module PagerDuty
  describe Client::Abilities do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/abilities" do
      it "returns abilities" do
        expected = ["sso","advanced_reports","teams","read_only_users","team_responders","service_support_hours","urgencies","manage_schedules","manage_api_keys","coordinated_responding","event_rules","beta_custom_actions","coordinated_responding_preview","preview_incident_alert_split","permissions_service","on_call_selfie","features_in_use_preventing_downgrade_to","feature_to_plan_map"]
        VCR.use_cassette("abilities/index") do
          assert_equal expected, @client.abilities
        end
      end

      it "doesn't return abilities for invalid key" do
        VCR.use_cassette("abilities/index.invalid") do
          @client = PagerDuty::Client.new(api_token: "y_NbAkKc66ryYTWUYzEu")
          assert_raises(PagerDuty::Unauthorized) do
            @client.abilities
          end
        end
      end      
    end    

    describe "/abilities/id" do
      it "properly verifies an ability" do
        VCR.use_cassette("abilities/show") do
          assert @client.ability("sso")
        end
      end

      it "properly does not verify and ability" do
        VCR.use_cassette("abilities/show.false") do
          refute @client.ability("sso2")
        end
      end
    end
  end
end