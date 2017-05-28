require "test_helper"
require "pp"

module PagerDuty
  describe Client::Notifications do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/notifications" do
      it "returns no notifications for account when since isn't set" do
        VCR.use_cassette("notifications/index/no_query") do
          assert_raises(PagerDuty::BadRequest) do
            notifications = @client.notifications
          end
        end
      end

      it "returns notifications for account" do
        VCR.use_cassette("notifications/index/query_since") do
          since = Time.parse("2017-05-10 23:48:27 UTC")
          until_time = Time.parse("2017-05-28 00:53:13 UTC")
          notifications = @client.notifications(since: since, until: until_time)
          assert_equal 25, notifications.count
        end
      end

      it "returns notifications for account in EST" do
        VCR.use_cassette("notifications/index/query_since_est") do
          since = Time.parse("2017-05-10 23:48:27 UTC")
          until_time = Time.parse("2017-05-28 00:53:13 UTC")
          notifications = @client.notifications(since: since, until: until_time, time_zone: "EST")
          assert_equal 25, notifications.count
          assert_equal "2017-05-10 18:48:34 -0500", notifications.first[:started_at].to_s
        end
      end

      it "returns notifications for account of type sms_notification" do
        VCR.use_cassette("notifications/index/query_since_sms_notification") do
          since = Time.parse("2017-05-10 23:48:27 UTC")
          until_time = Time.parse("2017-05-28 00:53:13 UTC")
          notifications = @client.notifications(since: since, until: until_time, filter: :sms_notification)
          assert_equal 0, notifications.count
        end
      end

      it "returns notifications for account of type email_notification" do
        VCR.use_cassette("notifications/index/query_since_email_notification") do
          since = Time.parse("2017-05-10 23:48:27 UTC")
          until_time = Time.parse("2017-05-28 00:53:13 UTC")
          notifications = @client.notifications(since: since, until: until_time, filter: :email_notification)
          assert_equal 25, notifications.count
        end
      end
  
    end       
  end
end