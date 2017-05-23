require "pager_duty/version"
require "pager_duty/response/raise_error"
require 'faraday/detailed_logger'
module PagerDuty

  # Default configuration options for {Client}
  module Default

    # Default API endpoint
    API_ENDPOINT = "https://api.pagerduty.com".freeze

    # Default User Agent header string
    USER_AGENT   = "PagerDuty Ruby Gem #{PagerDuty::VERSION}".freeze

    # Default media type
    MEDIA_TYPE   = "application/vnd.pagerduty+json;version=2".freeze

    # In Faraday 0.9, Faraday::Builder was renamed to Faraday::RackBuilder
    RACK_BUILDER_CLASS = defined?(Faraday::RackBuilder) ? Faraday::RackBuilder : Faraday::Builder
    
    # Default Faraday middleware stack
    MIDDLEWARE = RACK_BUILDER_CLASS.new do |builder|
      builder.response :detailed_logger
      builder.use PagerDuty::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[PagerDuty::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default access token from ENV
      # @return [String]
      def api_token
        ENV['PAGERDUTY_API_TOKEN']
      end

      # Default API endpoint from ENV or {API_ENDPOINT}
      # @return [String]
      def api_endpoint
        ENV['PAGERDUTY_API_ENDPOINT'] || API_ENDPOINT
      end

      # Default options for Faraday::Connection
      # @return [Hash]
      def connection_options
        {
          :headers => {
            :accept => default_media_type,
            :user_agent => user_agent
          }
        }
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [Faraday::RackBuilder or Faraday::Builder]
      def middleware
        MIDDLEWARE
      end

      # Default media type from ENV or {MEDIA_TYPE}
      # @return [String]
      def default_media_type
        MEDIA_TYPE
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        USER_AGENT
      end
    end
  end
end