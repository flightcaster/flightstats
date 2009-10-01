require File.dirname(__FILE__) + '/test_helper'

class FlightStatsTest < Test::Unit::TestCase
  
  def test_flightstats_query
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/xml?param=1&login.guid=test",
                         :body => "Example")
    assert_equal "Example", FlightStats.query({:param => '1'}).read
  end
  
  def test_throw_error_when_error_in_response
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/xml?param=2&login.guid=test",
                         :body => File.read("#{File.dirname(__FILE__)}/responses/error.xml"),
                         :status => ["401", "HTTPUnauthorized"])
    assert_raise StandardError do
      FlightStats.query({:param => '2'})
    end
  end
  
end