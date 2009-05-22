require File.join(File.dirname(__FILE__), "test_helper.rb")

describe FlightStats::Flight do
  
  before(:all) do
    class Zlib::GzipReader
      def initialize(tempfile)
        @stringg = tempfile.read
      end
      def read
        @stringg
      end
    end
  end
  
  it "raise error with invalid GUID" do
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/xml?login.guid=my_guid&airlineGetAirlinesInfo.airline.icaoCode=AAL&airlineGetAirlinesInfo.airlineGetAirlinesRequestedData.airlineDetails=true&Service=AirlineGetAirlinesService",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/invalid_guid.xml"))
    lambda { FlightStats::Airline.get(:exact, :icao_code => 'AAL') }.should raise_error(RuntimeError)
  end

  it "returns an empty array if it can't find the flight"

  it "return and array with one result"

  it "return an array with both legs of a flight"

  it "returns a list of flight updates of the last minute if not passing a time" do
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?lastAccessed=#{(Time.now - 60).utc.strftime("%Y-%m-%dT%H:%M")}&useUTC=true&login.guid=my_guid",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/flight/one_min_change_feed.xml"))
    FakeWeb.register_uri(:get, "http://www.pathfinder-xml.com/development/feed?login.guid=my_guid&file=4477945",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/flight/feed.gz_decompressed"))
    FlightStats::Flight.get_updates.size.should == 463
  end
  
  it "return a list of flight updates from the minute specifed" do
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?lastAccessed=#{(Time.now - 180).utc.strftime("%Y-%m-%dT%H:%M")}&useUTC=true&login.guid=my_guid",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/flight/multi_min_change_feed.xml"))
    FakeWeb.register_uri(:get, "http://www.pathfinder-xml.com/development/feed?login.guid=my_guid&file=4478320",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/flight/4478320.gz_decompressed"))
    FakeWeb.register_uri(:get, "http://www.pathfinder-xml.com/development/feed?login.guid=my_guid&file=4478323",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/flight/4478323.gz_decompressed"))
    FakeWeb.register_uri(:get, "http://www.pathfinder-xml.com/development/feed?login.guid=my_guid&file=4478326",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/flight/4478326.gz_decompressed"))
    FlightStats::Flight.get_updates(Time.now - 180).size.should == 1356
  end
  
end