require File.join(File.dirname(__FILE__), "test_helper.rb")

describe FlightStats::Airline do
  
  it "raise error with invalid GUID" do
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/xml?login.guid=my_guid&airlineGetAirlinesInfo.airline.icaoCode=AAL&airlineGetAirlinesInfo.airlineGetAirlinesRequestedData.airlineDetails=true&Service=AirlineGetAirlinesService",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/invalid_guid.xml"))
    lambda { FlightStats::Airline.get(:exact, :icao_code => 'AAL') }.should raise_error(RuntimeError)
  end

  it "returns nil if it can't find the airline" do
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/xml?login.guid=my_guid&airlineGetAirlinesInfo.airline.icaoCode=AAL&airlineGetAirlinesInfo.airlineGetAirlinesRequestedData.airlineDetails=true&Service=AirlineGetAirlinesService",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/airline/nil_results.xml"))
    FlightStats::Airline.get(:exact, :icao_code => 'AAL').should_equal nil
  end

  it "returns one airline when seraching for a valid airline" do
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/xml?login.guid=my_guid&airlineGetAirlinesInfo.airline.icaoCode=AAL&airlineGetAirlinesInfo.airlineGetAirlinesRequestedData.airlineDetails=true&Service=AirlineGetAirlinesService",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/airline/one_airline.xml"))
    result = FlightStats::Airline.get(:exact, :icao_code => 'AAL').attributes
    expected = FlightStats::Airline.new('name' => 'American Airlines',
                                        'flightstats_code' => 'AA',
                                        'iata_code' => 'AA',
                                        'icao_code' => 'AAL').attributes
    result.should == expected
  end
end