require "test_helper"
require "pp"

module PagerDuty
  describe Client::Incidents do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/incidents" do
      it "returns incidents for account" do
        VCR.use_cassette("incidents/index/no_query") do
          incidents = @client.incidents
          assert_equal 18, incidents.count
        end
      end

      it "returns incidents for account with date_range all" do
        VCR.use_cassette("incidents/index/date_range_all") do
          incidents = @client.incidents(date_range: :all)
          assert_equal 18, incidents.count
        end
      end

      it "returns incidents for account sorted by created_at desc" do
        VCR.use_cassette("incidents/index/created_at_desc") do
          incidents = @client.incidents(sort_by: "created_at:desc")
          assert_equal 18, incidents.count
          assert incidents.first[:created_at] > incidents.last[:created_at]
        end
      end      

      it "returns incidents for account sorted by created_at asc" do
        VCR.use_cassette("incidents/index/created_at_asc") do
          incidents = @client.incidents(sort_by: "created_at:asc")
          assert_equal 18, incidents.count
          assert incidents.last[:created_at] > incidents.first[:created_at]
        end
      end  

      it "returns incidents for account limited" do
        since = Time.parse("2017-05-10 23:48:27 UTC")
        until_time = Time.parse("2017-05-14 00:53:13 UTC")
        VCR.use_cassette("incidents/index/limited") do
          incidents = @client.incidents(since: since, until: until_time)
          assert_equal 3, incidents.count
          assert_equal 0, incidents.count { |e| e[:created_at] < since && e[:created_at] > until_time }
        end
      end  

      it "returns incidents for account with incident_key" do
        VCR.use_cassette("incidents/index/incident_key") do
          incidents = @client.incidents(incident_key: "2a74a331f2764cf7918edf78f5478ed1")
          assert_equal 1, incidents.count
        end
      end    

      it "returns incidents for account with time_zone" do
        VCR.use_cassette("incidents/index/time_zone") do
          incidents = @client.incidents(time_zone: "EST")
          assert_equal 18, incidents.count
          assert_equal "2017-05-10 18:48:27 -0500", incidents.first[:created_at].to_s
        end
      end      

      it "returns incidents for account with status triggered" do
        VCR.use_cassette("incidents/index/triggered") do
          incidents = @client.incidents(statuses: ["triggered"])
          assert_equal 2, incidents.count
          assert_equal 0, incidents.count { |e| e[:status] != "triggered" }
        end
      end  

      it "returns incidents for account with status acknowledged" do
        VCR.use_cassette("incidents/index/acknowledged") do
          incidents = @client.incidents(statuses: ["acknowledged"])
          assert_equal 1, incidents.count
          assert_equal 0, incidents.count { |e| e[:status] != "acknowledged" }
        end
      end  

      it "returns incidents for account with status resolved" do
        VCR.use_cassette("incidents/index/resolved") do
          incidents = @client.incidents(statuses: ["resolved"])
          assert_equal 16, incidents.count
          assert_equal 0, incidents.count { |e| e[:status] != "resolved" }
        end
      end 

      it "returns incidents for account with status all_statuses" do
        VCR.use_cassette("incidents/index/all_statuses") do
          incidents = @client.incidents(statuses: ["triggered", "acknowledged", "resolved"])
          assert_equal 18, incidents.count
          assert_equal 16, incidents.count { |e| e[:status] == "resolved" }
          assert_equal 1, incidents.count { |e| e[:status] == "acknowledged" }
          assert_equal 1, incidents.count { |e| e[:status] == "triggered" }
        end
      end                    

      it "returns incidents for account with multiple service_ids" do
        VCR.use_cassette("incidents/index/service_id.P7WQ2DJ.P407C9R") do
          incidents = @client.incidents(service_ids: ["P7WQ2DJ", "P407C9R"])
          assert_equal 2, incidents.count
          assert_equal 0, incidents.count { |e| e[:service][:id] != "P7WQ2DJ" && e[:service][:id] != "P407C9R" }
        end
      end            
        
      it "returns incidents for account with service_ids" do
        VCR.use_cassette("incidents/index/service_id.P407C9R") do
          incidents = @client.incidents(service_ids: ["P407C9R"])
          assert_equal 16, incidents.count
          assert_equal 0, incidents.count { |e| e[:service][:id] != "P407C9R" }
        end
      end          

      it "returns incidents for account with team_ids one" do
        VCR.use_cassette("incidents/index/team_ids.P7XILUG") do
          incidents = @client.incidents(team_ids: ["P7XILUG"])
          assert_equal 1, incidents.count
          assert_equal 0, incidents.count { |e| e[:teams].first[:id] != "P7XILUG" }
        end
      end  

      it "returns incidents for account with team_ids another" do
        VCR.use_cassette("incidents/index/team_ids.P1HE60B") do
          incidents = @client.incidents(team_ids: ["P1HE60B"])
          assert_equal 3, incidents.count
          assert_equal 0, incidents.count { |e| e[:teams].first[:id] != "P1HE60B" }
        end
      end   

      it "returns incidents for account with multiple team_ids" do
        VCR.use_cassette("incidents/index/team_ids.P1HE60B.P7XILUG") do
          incidents = @client.incidents(team_ids: ["P1HE60B", "P7XILUG"])
          assert_equal 3, incidents.count
          assert_equal 0, incidents.count { |e| e[:teams].first[:id] != "P1HE60B" }
        end
      end         

      it "returns incidents for account with user_ids one" do
        VCR.use_cassette("incidents/index/user_ids.PDU9IB6") do
          incidents = @client.incidents(user_ids: ["PDU9IB6"])
          assert_equal 1, incidents.count
          assert_equal "PDU9IB6", incidents.first[:assignments].first[:assignee][:id]
        end
      end 

      it "returns incidents for account with user_ids another" do
        VCR.use_cassette("incidents/index/user_ids.PGJLPE9") do
          incidents = @client.incidents(user_ids: ["PGJLPE9"])
          assert_equal 1, incidents.count
          assert_equal "PGJLPE9", incidents.first[:assignments].first[:assignee][:id]
        end
      end 

      it "returns incidents for account with multiple user_ids" do
        VCR.use_cassette("incidents/index/user_ids.PDU9IB6.PGJLPE9") do
          incidents = @client.incidents(user_ids: ["PDU9IB6", "PGJLPE9"])
          assert_equal 1, incidents.count
        end
      end 

      it "returns incidents for account with urgencies high" do
        VCR.use_cassette("incidents/index/urgencies.high") do
          incidents = @client.incidents(urgencies: ["high"])
          assert_equal 18, incidents.count
        end
      end 

      it "returns incidents for account with urgencies low" do
        VCR.use_cassette("incidents/index/urgencies.low") do
          incidents = @client.incidents(urgencies: ["low"])
          assert_equal 0, incidents.count
        end
      end 

      it "returns incidents for account with urgencies high and low" do
        VCR.use_cassette("incidents/index/urgencies.high.low") do
          incidents = @client.incidents(urgencies: ["high","low"])
          assert_equal 18, incidents.count
        end
      end 

      it "returns incidents for account including users" do
        VCR.use_cassette("incidents/index/include.users") do
          incidents = @client.incidents(include: ["users"])
          assert_equal 18, incidents.count
        end
      end 

      it "returns incidents for account including users and services" do
        VCR.use_cassette("incidents/index/include.users.services") do
          incidents = @client.incidents(include: ["users", "services"])
          assert_equal 18, incidents.count
        end
      end       
    end

    describe "/incidents GET" do
      it "returns incident for account" do
        VCR.use_cassette("incidents/incident") do
          id_incident = @client.incident(14)
          assert_equal 14, id_incident[:incident_number]
          assert_equal "PLK5EK9", id_incident[:id]  
          assert_equal "a4abde2e49784344855ff4f8f1f59b16", id_incident[:incident_key]
          
          
          key_incident = @client.incident("PLK5EK9")
          assert_equal 14, key_incident[:incident_number]
          assert_equal "a4abde2e49784344855ff4f8f1f59b16", key_incident[:incident_key]
          assert_equal "PLK5EK9", key_incident[:id]         
        end
      end      
    end

    describe "/incident_alerts GET" do
      it "returns incident_alerts for incident" do
        VCR.use_cassette("incidents/incident_alerts/P6M04C7") do
          alert = @client.incident_alerts("P6M04C7")
          assert_equal 1, alert.count
        end
      end  

      it "returns incident_alerts for incident status resolved" do
        VCR.use_cassette("incidents/incident_alerts/status_resolved") do
          alert = @client.incident_alerts("P6M04C7", statuses: :resolved)
          assert_equal 1, alert.count
        end
      end

      it "returns incident_alerts for incident with alerty key" do
        VCR.use_cassette("incidents/incident_alerts/alert_key") do
          alert = @client.incident_alerts("P6M04C7", alert_key: "acecf47ae60b490aa7a1bc6629a1749e")
          assert_equal 1, alert.count
        end
      end
    end 

    describe "/incident_log_entries GET" do
      it "returns incident_log_entries for incident" do
        VCR.use_cassette("incidents/incident_log_entries/P6M04C7") do
          log_entries = @client.incident_log_entries("P6M04C7")
          assert_equal 8, log_entries.count
        end
      end  

      it "returns incident_log_entries for incident with is_overview" do
        VCR.use_cassette("incidents/incident_log_entries/P6M04C7.is_overview") do
          log_entries = @client.incident_log_entries("P6M04C7", is_overview: true)
          assert_equal 3, log_entries.count
        end
      end        

      it "returns incident_log_entries for incident with is_overview" do
        VCR.use_cassette("incidents/incident_log_entries/P6M04C7.include") do
          log_entries = @client.incident_log_entries("P6M04C7", include: ["services", "channels"])
          assert_equal 8, log_entries.count
        end
      end   
    end        

    describe "/incident_notes GET" do
      it "returns incident_notes for incident with notes" do
        VCR.use_cassette("incidents/incident_notes/P9XCW88") do
          notes = @client.incident_notes("P9XCW88")
          assert_equal 1, notes.count
        end
      end  

      it "doesnt return incident_notes for incident with no notes" do
        VCR.use_cassette("incidents/incident_notes/P6M04C7") do
          notes = @client.incident_notes("P6M04C7")
          assert_equal 0, notes.count
        end
      end          
    end            
  end
end