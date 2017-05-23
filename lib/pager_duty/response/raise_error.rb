require "faraday"
require "pager_duty/error"

module PagerDuty
  # Faraday response middleware
  module Response

    # This class raises an Octokit-flavored exception based
    # HTTP status codes returned by the API
    class RaiseError < Faraday::Response::Middleware

      private

      def on_complete(response)
        if error = PagerDuty::Error.from_response(response)
          raise error
        end
      end
    end
  end
end
