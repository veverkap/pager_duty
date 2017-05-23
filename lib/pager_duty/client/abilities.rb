module PagerDuty
  class Client

    # Methods for the Abilities API
    #
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Abilities
    module Abilities
      # This describes your account's abilities by feature name, like `"teams"`.
      #
      # An ability may be available to your account based on things like your
      # pricing plan or account state.
      # @return [Array<Sawyer::Resource>] An array of strings representing abilities
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Abilities/get_abilities
      def abilities(options = {})
        response = get "/abilities", options
        response[:abilities]
      end
      alias :list_abilities :abilities

      # Test whether your account has a given ability.
      #
      # An ability may be available to your account based on things like your
      # pricing plan or account state.
      # @param ability [String] Ability to check
      # @return [Boolean] Whether your account has the ability
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Abilities/get_abilities_id
      def ability(ability, options = {})
        boolean_from_response :get, "/abilities/#{ability}", options
      end
      alias :has_ability :ability
    end
  end
end