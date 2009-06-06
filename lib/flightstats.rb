require 'libxml'
require 'open-uri'
require 'openssl'
require 'zlib'
require 'time'

require File.expand_path(File.join(File.dirname(__FILE__), '../ext/string'))
require File.expand_path(File.join(File.dirname(__FILE__), '../ext/hash'))
require File.expand_path(File.join(File.dirname(__FILE__), '../ext/openssl'))

module FlightStats
  @@api_server = "https://www.pathfinder-xml.com"
  @@api_base_path = "/development/xml"
  
  class << self

    # The base url for a request to FlightStats, includes the user id, account
    # id and the password.
    def api_path(base_path=@@api_base_path)
      base_path + "?" + {'login.guid' => FLIGHTSTATS_GUID}.parameterize
    end
    
    def query_path(params, base_path = nil)
      api_path(base_path) + "&" + params.parameterize
    end
    
    def query_url(params, base_path = nil)
      @@api_server + query_path(params, base_path)
    end
    
    # Sends a request to the Flightcaster server using the given params
    def query(params, base_path = nil)
      reponse = open(query_url(params, base_path)).read      
      LibXML::XML::Parser.string(reponse).parse
    end
    
  end
  
end

require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airline'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/flight'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/data_feed'))