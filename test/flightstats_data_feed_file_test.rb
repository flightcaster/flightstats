require File.dirname(__FILE__) + '/test_helper'

class FlightStats::DataFeed::FileTest < Test::Unit::TestCase

  def test_should_find_ten_updates
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&useUTC=true&lastAccessed=#{Time.now.utc.strftime("%Y-%m-%dT%H:%M")}",
                         :body => File.read("#{File.dirname(__FILE__)}/responses/feed_file_list.xml"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551477",
                         :body => File.read("#{File.dirname(__FILE__)}/responses/test1.gz"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551480",
                         :body => File.read("#{File.dirname(__FILE__)}/responses/test2.gz"))

    count = 0
    FlightStats::DataFeed.new.files do |file|
      file.updates do |update|
        count += 1
      end
    end
    assert_equal 11, count
  end
  
  def test_should_find_5_updates_when_reading_file
    data_file = File.new("#{File.dirname(__FILE__)}/responses/test1.gz")
    file = FlightStats::DataFeed::File.new(data_file)
    count = 0
    file.updates do |update|
      count += 1
    end
    assert_equal(5, count)
  end

  def test_should_check_correctness_of_data
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&useUTC=true&lastAccessed=#{Time.now.utc.strftime("%Y-%m-%dT%H:%M")}",
                         :body => File.read("#{File.dirname(__FILE__)}/responses/feed_file_list.xml"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551477",
                        :body => File.read("#{File.dirname(__FILE__)}/responses/test1.gz"))
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&file=4551480",
                        :body => File.read("#{File.dirname(__FILE__)}/responses/test2.gz"))
                      
    changes = Array.new
    FlightStats::DataFeed.new.files do |file|
      file.updates do |update|
        changes << update
      end
    end
    update = changes[0]
    assert_equal(Time.utc(2009,6,8,20,30,0,43), update.timestamp)
    assert_equal('ASDI', update.source)
    assert_equal('STATUS-Active', update.event)
    assert_equal('ARD- New=06/08/09 16:24, ERD- Old=06/08/09 16:26 New=06/08/09 16:24, ERA- Old=06/08/09 17:45 New=06/08/09 17:42, STATUS- Old=S New=A', update.data_updated)
    
    assert_equal('162197049', update.flight.id)
    assert_equal('753', update.flight.number)
    assert_equal(Time.utc(2009,6,8,16,26), update.flight.scheduled_local_runway_departure_time)
    assert_equal(Time.utc(2009,6,8,16,24), update.flight.estimated_local_runway_departure_time)
    assert_equal(Time.utc(2009,6,8,16,24,52), update.flight.actual_local_runway_departure_time)
    assert_equal(Time.utc(2009,6,8,17,45), update.flight.scheduled_local_runway_arrival_time)
    assert_equal(Time.utc(2009,6,8,17,42), update.flight.estimated_local_runway_arrival_time)
    assert_equal('A', update.flight.creator_code)
    assert_equal('A', update.flight.status_code)
    assert_equal(79, update.flight.scheduled_air_time)
    assert_equal(-4, update.flight.departure_airport_timezone_offset)
    assert_equal(-4, update.flight.arrival_airport_timezone_offset)
    assert_equal(Time.utc(2009,6,8,16,26), update.flight.local_departure_time)
    assert_equal(Time.utc(2009,6,8,17,45), update.flight.local_arrival_time)

    assert_equal('G4', update.flight.airline.code)
    assert_equal('AAY', update.flight.airline.icao_code)
    assert_nil(update.flight.airline.iata_code)
    assert_nil(update.flight.airline.faa_code)
    assert_nil(update.flight.airline.name)

    assert_equal('SFB', update.flight.origin.code)
    assert_equal('KSFB', update.flight.origin.icao_code)
    assert_nil(update.flight.origin.iata_code)
    assert_nil(update.flight.origin.faa_code)
    assert_nil(update.flight.origin.name)
    
    assert_equal('GSO', update.flight.destination.code)
    assert_equal('KGSO', update.flight.destination.icao_code)
    assert_nil(update.flight.destination.iata_code)
    assert_nil(update.flight.destination.faa_code)
    assert_nil(update.flight.destination.name)    

    assert_equal([], update.flight.codeshares)

    update = changes[6]
    assert_equal(Time.utc(2009,6,8,20,27,1,110), update.timestamp)
    assert_equal('Airline (CO)', update.source)
    assert_equal('Time Adjustment', update.event)
    assert_equal('EGD- New=06/08/09 19:35, EGA- New=06/08/09 23:35, DGATE- New=C-30', update.data_updated)
    
    assert_equal('161861862', update.flight.id)
    assert_equal('1417', update.flight.number)
    assert_equal(Time.utc(2009,6,8,19,35), update.flight.published_local_departure_time)
    assert_equal(Time.utc(2009,6,8,23,35), update.flight.published_local_arrival_time)
    assert_equal(Time.utc(2009,6,8,19,35), update.flight.scheduled_local_gate_departure_time)
    assert_equal(Time.utc(2009,6,8,19,35), update.flight.estimated_local_gate_departure_time)
    assert_equal(Time.utc(2009,6,8,23,35), update.flight.scheduled_local_gate_arrival_time)
    assert_equal(Time.utc(2009,6,8,23,35), update.flight.estimated_local_gate_arrival_time)    
    assert_equal(Time.utc(2009,6,8,19,56), update.flight.scheduled_local_runway_departure_time)
    assert_equal(Time.utc(2009,6,8,19,56), update.flight.estimated_local_runway_departure_time)
    assert_equal(Time.utc(2009,6,8,23,21), update.flight.scheduled_local_runway_arrival_time)
    assert_equal(Time.utc(2009,6,8,23,21), update.flight.estimated_local_runway_arrival_time)
    assert_nil(update.flight.actual_local_runway_departure_time)
    assert_equal('O', update.flight.creator_code)
    assert_equal('S', update.flight.status_code)
    assert_equal(145, update.flight.scheduled_air_time)
    assert_equal(180, update.flight.scheduled_block_time)
    assert_equal(-5, update.flight.departure_airport_timezone_offset)
    assert_equal(-4, update.flight.arrival_airport_timezone_offset)
    assert_equal(Time.utc(2009,6,8,19,35), update.flight.local_departure_time)
    assert_equal(Time.utc(2009,6,8,23,35), update.flight.local_arrival_time)
    assert_equal('735', update.flight.scheduled_aircraft_type)
    assert_equal('C-30', update.flight.departure_gate)
    assert_equal('C', update.flight.departure_terminal)
    assert_nil(update.flight.arrival_terminal)
    
    assert_equal('CO', update.flight.airline.code)
    assert_equal('COA', update.flight.airline.icao_code)
    assert_nil(update.flight.airline.iata_code)
    assert_nil(update.flight.airline.faa_code)
    assert_nil(update.flight.airline.name)

    assert_equal('IAH', update.flight.origin.code)
    assert_equal('KIAH', update.flight.origin.icao_code)
    assert_nil(update.flight.origin.iata_code)
    assert_nil(update.flight.origin.faa_code)
    assert_nil(update.flight.origin.name)
    
    assert_equal('PIT', update.flight.destination.code)
    assert_equal('KPIT', update.flight.destination.icao_code)
    assert_nil(update.flight.destination.iata_code)
    assert_nil(update.flight.destination.faa_code)
    assert_nil(update.flight.destination.name)    

    assert_equal(1, update.flight.codeshares.size)
    assert_equal('109977276', update.flight.codeshares.first.id)
    assert_equal('2317', update.flight.codeshares.first.number)
    assert_equal('L', update.flight.codeshares.first.designator)
    assert_equal(Time.utc(2009,6,8,19,35), update.flight.codeshares.first.published_local_departure_time)
    assert_equal(Time.utc(2009,6,8,23,35), update.flight.codeshares.first.published_local_arrival_time)
    assert_equal('CM', update.flight.codeshares.first.airline.code)
    assert_equal('CM', update.flight.codeshares.first.airline.iata_code)
  end
end