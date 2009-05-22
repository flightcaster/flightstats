require File.join(File.dirname(__FILE__), "test_helper.rb")

describe FlightStats::Airline do

  it "raise error with invalid GUID" do
    eval("::FLIGHTSTATS_GUID = '234i2340will-fail234wrong-guid'")
    FakeWeb.register_uri(:get, "http://www.pathfinder-xml.com/development/xml?login.guid=234i2340will-fail234wrong-guid&airlineGetAirlinesInfo.airline.icaoCode=AAL&airlineGetAirlinesInfo.airlineGetAirlinesRequestedData.airlineDetails=true&Service=AirlineGetAirlinesService",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/invalid_guid.xml"))
    lambda { FlightStats::Airline.get(:exact, :icao_code => 'AAL') }.should raise_error(RuntimeError)
  end

end