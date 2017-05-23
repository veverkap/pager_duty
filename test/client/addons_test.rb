require "test_helper"
require "pp"

module PagerDuty
  describe Client::Addons do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/addons" do
      it "returns addons for account" do
        expected = { 
          id: "P58BJWA", 
          type: "full_page_addon", 
          summary: "Full Page Addon", 
          self: "https://api.pagerduty.com/addons/P58BJWA", 
          html_url: nil, 
          name: "Full Page Addon", 
          src: "https://intranet.example.com/status", 
          services: []}
        VCR.use_cassette("addons/index") do
          addons = @client.addons
          assert_equal 2, addons.count
          expected.keys.each do |key|
            assert_equal expected[key], addons.first[key]
          end
        end
      end

      it "returns addons with services" do
        VCR.use_cassette("addons/index.with_services") do
          addons = @client.addons(include_services: true)
          assert_equal 0, addons.first[:services].count
          second = addons[1]
          assert_equal 1, second[:services].count
          assert_equal "P407C9R", second[:services].first[:id]
        end        
      end

      # TODO: Follow up why this doesn't exclude unassociated
      it "returns addons with services by service id" do
        VCR.use_cassette("addons/index.with_services_by_service_id") do
          addons = @client.addons(include_services: true, service_ids: ["P407C9R"])
          assert_equal 0, addons.first[:services].count
          second = addons[1]
          assert_equal 1, second[:services].count
          assert_equal "P407C9R", second[:services].first[:id]
        end
      end     

      it "returns addons filtered to full page addon" do
        VCR.use_cassette("addons/index.with_services_filtered_to_full_page_addon") do
          addons = @client.addons(filter: :full_page_addon)
          assert 1, addons.select { |e| e[:type] == "full_page_addon" }.count
          assert 0, addons.select { |e| e[:type] == "incident_show_addon" }.count
        end
      end            
    end

    describe "/addons/{id}" do
      it "will get an addon by id" do
        expected = Set.new [:id, :type, :summary, :self, :html_url, :name, :src, :services]
        VCR.use_cassette("addons/get_by_id") do
          addon = @client.addon("PE3MKYN")
          assert_equal "PE3MKYN", addon[:id] 
          assert_equal "incident_show_addon", addon[:type]
          assert_equal expected, addon.fields
        end
      end

      it "won't get a deleted addon by id" do
        VCR.use_cassette("addons/get_deleted") do
          assert_raises(PagerDuty::NotFound) do
            @client.addon("P5R5GQ4")
          end
        end
      end
    end   

    describe "/addons POST" do
      it "will not create an addon without a type" do
        VCR.use_cassette("addons/create.no_type") do
          assert_raises(PagerDuty::BadRequest) do
            @client.install_addon()
          end
        end
      end

      it "will not create an addon without a name" do
        VCR.use_cassette("addons/create.no_name") do
          assert_raises(PagerDuty::BadRequest) do
            @client.install_addon(type: "full_page_addon")
          end
        end
      end  

      it "will not create an addon without a src" do
        VCR.use_cassette("addons/create.no_src") do
          assert_raises(PagerDuty::BadRequest) do
            @client.install_addon(type: "full_page_addon", name: "Test")
          end
        end
      end  

      it "will not create an addon without an HTTPS src" do
        VCR.use_cassette("addons/create.no_https_src") do
          assert_raises(PagerDuty::BadRequest) do
            @client.install_addon(type: "full_page_addon", name: "Test", src: "http://www.example.com")
          end
        end
      end  

      it "will create an addon with everything" do
        VCR.use_cassette("addons/create.all_set") do
          response = @client.install_addon(type: :full_page_addon, name: "Test", src: "https://www.example.com")
          assert_equal "full_page_addon", response[:type]
          assert_equal "Test", response[:name]
          assert_equal "https://www.example.com", response[:src]
        end
      end              
    end

    describe "/addons DELETE" do
      it "will not delete an addon with readonly key" do
        VCR.use_cassette("addons/delete.P58BJWA") do
          @client = PagerDuty::Client.new(api_token: "READONLY")
          assert_raises(PagerDuty::Forbidden) do
            @client.delete_addon("P58BJWA")
          end
        end
      end      

      it "will delete an addon with an id" do
        VCR.use_cassette("addons/delete.P5R5GQ4") do
          assert @client.delete_addon("P5R5GQ4")
        end
      end
    end    

    describe "/addons/{id} PUT" do
      it "will update addon by id" do
        VCR.use_cassette("addons/update_by_id") do
          existing = @client.addon("PE3MKYN")
          assert_equal "Updated Incident Addon", existing[:name]
          assert_equal "https://intranet.example.com/new_url", existing[:src]
          response = @client.update_addon("PE3MKYN", type: "incident_show_addon", name: "Newly Updated Incident Addon", src: "https://intranet.example.com/newest_url")
          assert_equal "Newly Updated Incident Addon", response[:name]
          assert_equal "https://intranet.example.com/newest_url", response[:src]
        end
      end

      it "will update addon by id changing only name" do
        VCR.use_cassette("addons/update_by_id_name_only") do
          existing = @client.addon("PE3MKYN")
          response = @client.update_addon("PE3MKYN", name: "Updated Again")
          assert_equal "Updated Again", response[:name]
          assert_equal existing[:src], response[:src]
        end
      end 
    end  
  end
end
