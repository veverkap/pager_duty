module PagerDuty
  module Configurable
    attr_accessor :api_token, :api_endpoint, :default_media_type, :user_agent, :middleware, :connection_options
    
    class << self
      def keys
        @keys ||= [
          :api_token,
          :api_endpoint,
          :default_media_type,
          :user_agent,
          :middleware,
          :connection_options
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      PagerDuty::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", PagerDuty::Default.options[key])
      end
      self
    end
    alias setup reset!    
  end
end