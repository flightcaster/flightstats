require 'libxml'
require 'net/https'
require 'open-uri'
require 'date'
require 'time'
require 'zlib'

require File.expand_path(File.join(File.dirname(__FILE__), '../ext/string'))
require File.expand_path(File.join(File.dirname(__FILE__), '../ext/hash'))

module FlightStats
  VERSION = '0.0.1'
  
  @api_server = "www.pathfinder-xml.com"
  @api_base_path = "/development/xml"
  
  class << self
    
    # The base url for a request to FlightStats, includes the user id, account
    # id and the password.
    def api_path
      params = if FLIGHTSTATS_GUID
        { 'login.guid' => FLIGHTSTATS_GUID }
      else
        { 'login.accountID' => FLIGHTSTATS_ACCOUNT_ID.to_s,
          'login.userID' => FLIGHTSTATS_USER_ID.to_s,
          'login.password' => FLIGHTSTATS_PASSWORD.to_s}
      end
      @api_base_path + "?" + params.collect { |k, v| "#{k}=#{v}"}.join('&')
    end
    
    # Sends a request to the Flightcaster server using the given params
    def query(params)
      url = api_path + "&" + params.collect { |k, v| "#{k.to_s}=#{v.to_s}"}.join('&')

      http = Net::HTTP.new(@api_server, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      reponse = http.get(url).body
      
      LibXML::XML::Parser.string(reponse).parse
    end
    
  end
  
end

require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airline'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/metar'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/weather_forecast'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/flight'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay/closed_delay'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay/general_delay'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay/general_arrival_delay'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay/general_departure_delay'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay/general_arrival_delay'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay/ground_delay'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airport/delay/ground_stop_delay'))
