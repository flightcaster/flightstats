require File.dirname(__FILE__) + '/test_helper'

class DelayFeedTest < Test::Unit::TestCase
  
  def test_should_find_two_files
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&useUTC=true&lastAccessed=#{Time.now.utc.strftime("%Y-%m-%dT%H:%M")}",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/feed_file_list.xml"))
    assert_equal 2, FlightStats::DataFeed.new.files.size
  end
  
  def test_should_find_ten_updates
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&useUTC=true&lastAccessed=#{Time.now.utc.strftime("%Y-%m-%dT%H:%M")}",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/feed_file_list.xml"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551477",
                        :string => File.read("#{File.dirname(__FILE__)}/responses/test1.gz"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551480",
                        :string => File.read("#{File.dirname(__FILE__)}/responses/test2.gz"))
                        
    count = 0
    FlightStats::DataFeed.new.each do |f|
      count += 1
    end
    assert_equal 10, count
  end

  def test_should_check_correctness_of_data
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&useUTC=true&lastAccessed=#{Time.now.utc.strftime("%Y-%m-%dT%H:%M")}",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/feed_file_list.xml"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551477",
                        :string => File.read("#{File.dirname(__FILE__)}/responses/test1.gz"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551480",
                        :string => File.read("#{File.dirname(__FILE__)}/responses/test2.gz"))
                        
    changes = Array.new
    FlightStats::DataFeed.new.each do |f|
      changes << f
    end
    att = changes[0].attributes
    assert_equal att["estimated_runway_arrival_time"].to_s, "Mon Jun 08 21:42:00 UTC 2009"
    assert_equal att["number"], 753
    assert_equal att["origin_icao_code"], "KSFB"
    assert_equal att["creator_code"], "A"
    assert_equal att["estimated_runway_departure_time"].to_s, "Mon Jun 08 20:24:00 UTC 2009"
    assert_equal att["scheduled_runway_departure_time"].to_s, "Mon Jun 08 20:26:00 UTC 2009"
    assert_equal att["codeshares"], []
    assert_equal att["departure_time"].to_s, "Mon Jun 08 20:26:00 UTC 2009"
    assert_equal att["actual_runway_departure_time"].to_s, "Mon Jun 08 20:24:52 UTC 2009"
    assert_equal att["scheduled_runway_arrival_time"].to_s, "Mon Jun 08 21:45:00 UTC 2009"
    assert_equal att["arrival_airport_time_zone_offset"], -4
    assert_equal att["destination_icao_code"], "KGSO"
    assert_equal att["airline"].attributes, {"iata_code"=>"G4", "icao_code"=>"AAY"}
    assert_equal att["arrival_time"].to_s, "Mon Jun 08 21:45:00 UTC 2009"
    assert_equal att["departure_airport_time_zone_offset"], -4
    assert_equal att["status_code"], "A"
    assert_equal att["updated_at"].to_s, "Mon Jun 08 20:30:00 UTC 2009"
    assert_equal att["scheduled_air_time"], 79
    assert_equal att["history_id"], 162197049
    
    att = changes[6].attributes
    assert_equal att["estimated_runway_arrival_time"].to_s, "Tue Jun 09 03:21:00 UTC 2009"
    assert_equal att["departure_terminal"], "C"
    assert_equal att["departure_gate"], "C-30"
    assert_equal att["updated_at"].to_s, "Mon Jun 08 20:27:01 UTC 2009"
    assert_equal att["published_departure_time"].to_s, "Tue Jun 09 00:35:00 UTC 2009"
    assert_equal att["arrival_terminal"], ""
    assert_equal att["number"], 1417
    assert_equal att["scheduled_gate_arrival_time"].to_s, "Tue Jun 09 03:35:00 UTC 2009"
    assert_equal att["origin_icao_code"], "KIAH"
    assert_equal att["scheduled_gate_departure_time"].to_s, "Tue Jun 09 00:35:00 UTC 2009"
    assert_equal att["creator_code"], "O"
    assert_equal att["estimated_runway_departure_time"].to_s, "Tue Jun 09 00:56:00 UTC 2009"
    assert_equal att["scheduled_runway_departure_time"].to_s, "Tue Jun 09 00:56:00 UTC 2009"
    assert_equal att["codeshares"], [{:airline_icao=>nil, :number=>"2317", :designator=>"L"}]
    assert_equal att["departure_time"].to_s, "Tue Jun 09 00:35:00 UTC 2009"
    assert_equal att["scheduled_block_time"], 180
    assert_equal att["scheduled_aircraft_type"], "735"
    assert_equal att["scheduled_runway_arrival_time"].to_s, "Tue Jun 09 03:21:00 UTC 2009"
    assert_equal att["arrival_airport_time_zone_offset"], -4
    assert_equal att["destination_icao_code"], "KPIT"
    assert_equal att["airline"].attributes, {"iata_code"=>"CO", "icao_code"=>"COA"}
    assert_equal att["estimated_gate_arrival_time"].to_s, "Tue Jun 09 03:35:00 UTC 2009"
    assert_equal att["arrival_time"].to_s, "Tue Jun 09 03:35:00 UTC 2009"
    assert_equal att["published_arrival_time"].to_s, "Tue Jun 09 03:35:00 UTC 2009"
    assert_equal att["departure_airport_time_zone_offset"], -5
    assert_equal att["status_code"], "S"
    assert_equal att["estimated_gate_departure_time"].to_s, "Tue Jun 09 00:35:00 UTC 2009"
    assert_equal att["scheduled_air_time"], 145
    assert_equal att["history_id"], 161861862

  end
end