require "test_helper"
require "pp"

module PagerDuty
  describe Client::MaintenanceWindows do
    before do
      @client = PagerDuty::Client.new(api_token: test_api_token)
    end

    describe "/maintenance_windows" do
      it "returns maintenance_windows for account" do
        VCR.use_cassette("maintenance_windows/index/no_query") do
          maintenance_windows = @client.maintenance_windows
          assert_equal 1, maintenance_windows.count
        end
      end

      it "returns maintenance_windows for account with query scheduled" do
        VCR.use_cassette("maintenance_windows/index/query") do
          maintenance_windows = @client.maintenance_windows(query: "scheduled")
          assert_equal 1, maintenance_windows.count
          assert_equal "This is scheduled", maintenance_windows.first[:description]
        end
      end      

      it "returns maintenance_windows for account with query future" do
        VCR.use_cassette("maintenance_windows/index/future") do
          maintenance_windows = @client.maintenance_windows(filter: "future")
          assert_equal 1, maintenance_windows.count
          assert_equal "This is scheduled", maintenance_windows.first[:description]
        end
      end            

      it "returns maintenance_windows for account with query ongoing" do
        VCR.use_cassette("maintenance_windows/index/ongoing") do
          maintenance_windows = @client.maintenance_windows(filter: "ongoing")
          assert_equal 1, maintenance_windows.count
          assert_equal "This is scheduled", maintenance_windows.first[:description]
        end
      end  

      it "returns maintenance_windows for account with query all" do
        VCR.use_cassette("maintenance_windows/index/all") do
          maintenance_windows = @client.maintenance_windows(filter: "all")
          assert_equal 1, maintenance_windows.count
          assert_equal "This is scheduled", maintenance_windows.first[:description]
        end
      end 

      it "returns maintenance_windows for account with query past" do
        VCR.use_cassette("maintenance_windows/index/past") do
          maintenance_windows = @client.maintenance_windows(filter: "past")
          assert_equal 1, maintenance_windows.count
          assert_equal "This is scheduled", maintenance_windows.first[:description]
        end
      end               

      # it "returns log_entries for account with time_zone" do
      #   VCR.use_cassette("log_entries/index/time_zone") do
      #     log_entries = @client.log_entries(time_zone: "EST")
      #     assert_equal 100, log_entries.count
      #     assert_equal "2017-05-26 18:40:59 -0500", log_entries.first[:created_at].to_s
      #   end
      # end           
    end

    describe "/maintenance_windows GET" do
      it "returns maintenance_window for account" do
        VCR.use_cassette("maintenance_windows/get.PIVGPA6") do
          maintenance_window = @client.maintenance_window("PIVGPA6")
          assert_equal "PIVGPA6", maintenance_window[:id]
          assert_equal "2017-05-27T11:17:00-04:00", maintenance_window[:start_time].to_s
          assert_equal "P407C9R", maintenance_window[:services].first[:id]
        end
      end              
    end         

    describe "/maintenance_windows POST" do
      it "creates maintenance_window for account" do
        VCR.use_cassette("maintenance_windows/create") do
          maintenance_window = @client.create_maintenance_window("pagerduty@veverka.net", 
                                                                 "2017-05-27T12:17:00-04:00",
                                                                 "2017-05-27T12:19:00-04:00",
                                                                 "Generic MaintenanceWindow",
                                                                 "P407C9R")
          assert_equal "PQA2SWT", maintenance_window[:id]
          assert_equal "2017-05-27T12:17:00-04:00", maintenance_window[:start_time].to_s
          assert_equal "2017-05-27T12:19:00-04:00", maintenance_window[:end_time].to_s
        end
      end              
    end 

    describe "/maintenance_windows DELETE" do
      it "deletes maintenance_window for account" do
        VCR.use_cassette("maintenance_windows/delete") do
          maintenance_window = @client.maintenance_window("PQA2SWT")

          assert @client.delete_maintenance_window("PQA2SWT")

          assert_raises(PagerDuty::NotFound) do
            maintenance_window = @client.maintenance_window("PQA2SWT")
          end
        end
      end    

      it "doesn't delete maintenance_window for account in the past" do
        VCR.use_cassette("maintenance_windows/delete.in.past") do
          maintenance_window = @client.maintenance_window("PIVGPA6")

          assert_raises(PagerDuty::ClientError) do
            @client.delete_maintenance_window("PIVGPA6")
          end

        end
      end                    
    end   

    describe "/maintenance_windows PUT" do
      it "updates maintenance_window for account" do
        VCR.use_cassette("maintenance_windows/update") do
          id = "P3BSCJV"
          maintenance_window = @client.maintenance_window(id)

          @client.update_maintenance_window(id, 
                                            maintenance_window[:start_time], 
                                            maintenance_window[:end_time], 
                                            "Updated Description", 
                                            maintenance_window[:services].first[:id])
          maintenance_window = @client.maintenance_window(id)

          assert_equal "Updated Description", maintenance_window[:description]
        end
      end    
                  
    end         
  end
end