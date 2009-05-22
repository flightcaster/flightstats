require File.join(File.dirname(__FILE__), "test_helper.rb")

describe FlightStats::Airline do

  it "raise error with invalid GUID" do
    eval("::FLIGHTSTATS_GUID = 'this-guid-id-will-fail123100923'")
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/xml?login.guid=this-guid-id-will-fail123100923&airlineGetAirlinesInfo.airline.icaoCode=AAL&airlineGetAirlinesInfo.airlineGetAirlinesRequestedData.airlineDetails=true&Service=AirlineGetAirlinesService",
                         :string => File.read("#{File.dirname(__FILE__)}/responses/invalid_guid.xml"))
    lambda { FlightStats::Airline.get(:exact, :icao_code => 'AAL') }.should raise_error(RuntimeError)
  end
  
  

end