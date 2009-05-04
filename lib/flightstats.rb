require 'rubygems'
require 'libxml'
require 'open-uri'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class String
  def underscore
    self.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end


module FlightStats
  
  @base_url = "https://www.pathfinder-xml.com/development/xml"
  
  def self.api_url
    params = {'login.accountID' => FLIGHTSTATS_ACCOUNT_ID,
              'login.userID' => FLIGHTSTATS_USER_ID,
              'login.password' => FLIGHTSTATS_PASSWORD}
    @base_url + "?" + params.collect { |k, v| "#{k}=#{v}"}.join('&')
  end
  
  def self.query(params)
    url = api_url + "&" + params.collect { |k, v| "#{k.to_s}=#{v.to_s}"}.join('&')
    puts url
    LibXML::XML::Parser.io(open(url)).parse
  end
  
end

require 'flightstats/airline'
require 'flightstats/airport'
require 'flightstats/metar_report'
require 'flightstats/weather_report'
require 'flightstats/flight'
require 'flightstats/airport/delay'
require 'flightstats/airport/delay/closed_delay'
require 'flightstats/airport/delay/general_delay'
require 'flightstats/airport/delay/general_arrival_delay'
require 'flightstats/airport/delay/general_departure_delay'
require 'flightstats/airport/delay/general_arrival_delay'
require 'flightstats/airport/delay/ground_delay'
require 'flightstats/airport/delay/ground_stop_delay'