require "time"
module PagerDuty
  class Client
    # Module encompassing interactions with the vendors API endpoint
    #
    # A PagerDuty vendor represents a specific type of integration. 
    #
    # AWS Cloudwatch, Splunk, Datadog, etc are all examples of vendors that can be integrated in PagerDuty by making an integration.
    #
    # Vendored integrations (when compared to generic email and API integrations) are automatically configured with the right API or email filtering settings for inbound events from that vendor. 
    #
    # Some vendors also have associated integration guides on the PagerDuty support site.
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Vendors
    module Vendors
      # List all vendors.
      # @param options [Sawyer::Resource] A customizable set of options.
      # @return [Array<Sawyer::Resource>] An array of hashes representing vendors
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Vendors/get_vendors
      def vendors(options = {})
        response = get "/vendors", options
        response[:vendors]
      end
      alias :list_vendors :vendors

      # Get details about one specific vendor.
      # 
      # @param id [String] A vendor id (required)
      # @param options [Sawyer::Resource] A customizable set of options.
      # @return [Sawyer::Resource] A hash representing vendor
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Vendors/get_vendors_id
      def vendor(id, options = {})
        response = get "/vendors/#{id}", options
        response[:vendor]
      end
      alias :get_vendor :vendor
    end
  end
end