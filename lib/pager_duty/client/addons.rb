module PagerDuty
  class Client
    # Third-party developers can write their own add-ons to PagerDuty's UI, to
    # add HTML to the product.
    # 
    # Given a configuration containing a <tt>src</ttd> parameter, that URL will be embedded in an iframe on a page that's available to users from a drop-down menu.
    #
    # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Add-ons
    module Addons
      # List add-ons
      #
      # @param options [Sawyer::Resource] A customizable set of options.
      # @option options [boolean]       :include_services (false) Whether to include referenced services
      # @option options [Array<String>] :service_ids ids of services to include
      # @option options [String]        :filter (nil) Filter to type of addon (one of <tt>:full_page_addon</tt> or <tt>:incident_show_addon</tt>)
      #
      # @return [Array<Sawyer::Resource>] An array of hashes representing add-ons
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Add-ons/get_addons      
      def addons(options = {})
        query = Hash.new
        query["include[]"]     = "services" if options.fetch(:include_services, false)
        query["service_ids[]"] = options.fetch(:service_ids, [])
        query["filter"]        = options[:filter] if options[:filter] && [:full_page_addon, :incident_show_addon].include?(options[:filter])

        response = get "/addons", options.merge({query: query})
        response[:addons]
      end
      alias :list_addons :addons


      # Get details about an existing add-on.
      # @param id      [String] PagerDuty id for addon
      # @param options [Sawyer::Resource] A customizable set of options.
      # 
      # @return [Sawyer::Resource] A hash representing add-on
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Add-ons/get_addons_id
      def addon(id, options = {})
        response = get "/addons/#{id}", options
        response[:addon]
      end
      alias :get_addon :addon

      # Creates an add-on in the associated account
      # 
      # @param type    [Symbol] Type of addon (one of <tt>:full_page_addon</tt> or <tt>:incident_show_addon</tt>)
      # @param name    [String] name of addon
      # @param src     [String] HTTPS URL of addon
      # @param options [Sawyer::Resource] A customizable set of options.
      # 
      # @return [Sawyer::Resource] A hash representing add-on created
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Add-ons/post_addons      
      def install_addon(type, name, src, options = {})
        params = { 
          addon: {
            type: type,
            name: name,
            src:  src
          }
        }
        response = post "/addons", options.merge(params)
        response[:addon]
      end
      alias :create_addon :install_addon

      # 
      # Remove an existing add-on.
      # @param id [String] addon ID
      # 
      # @return [Boolean]
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Add-ons/delete_addons_id
      def delete_addon(id)
        boolean_from_response :delete, "/addons/#{id}"
      end

      # 
      # Updates addon
      # @param id       [String] Addon ID
      # @param options  [Sawyer::Resource] A customizable set of options.
      # @option options [String] :type Type of addon (one of <tt>:full_page_addon</tt> or <tt>:incident_show_addon</tt>)
      # @option options [String] :name Name of addon
      # @option options [String] :src HTTPS URL of addon
      # 
      # @return [Sawyer::Resource] A hash representing add-on updated
      # @see https://v2.developer.pagerduty.com/v2/page/api-reference#!/Add-ons/put_addons_id
      def update_addon(id, options = {})
        # params = {addon: {}}
        # params[:addon][:type] = options[:type] if options.key?(:type)
        # params[:addon][:name] = options[:name] if options.key?(:name)
        # params[:addon][:src]  = options[:src] if options.key?(:src)
        response = put "addons/#{id}", options
        response[:addon]
      end      
    end
  end
end