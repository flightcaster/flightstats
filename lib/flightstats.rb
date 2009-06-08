require 'libxml'
require 'net/https'
require 'uri'
require 'zlib'
require 'time'

require File.expand_path(File.join(File.dirname(__FILE__), '../ext/string'))
require File.expand_path(File.join(File.dirname(__FILE__), '../ext/hash'))

module FlightStats
  @@api_server = "https://www.pathfinder-xml.com"
  @@api_base_path = "/development/xml"
  
  class << self

    # The base url for a request to FlightStats, includes the user id, account
    # id and the password.
    def api_path(base_path=@@api_base_path)
      base_path + "?" + parameterize({'login.guid' => FLIGHTSTATS_GUID})
    end
    
    def query_path(params, base_path = nil)
      api_path(base_path) + "&" + parameterize(params)
    end
    
    def query_url(params, base_path = nil)
      @@api_server + query_path(params, base_path)
    end
    
    def query_uri(params, base_path = nil)
      URI.parse(query_url(params, base_path))
    end

    def raw_query(params, base_path = nil)
      uri = query_uri(params, base_path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      StringIO.new(http.get(uri.path+'?'+uri.query).body)
    end
    
    def parameterize(hash)
      hash.collect { |key, value| "#{key}=#{value}" }.join('&')
    end
    
    # Sends a request to the Flightcaster server using the given params
    def query(params, base_path = nil)
      reponse = raw_query(params, base_path).read
      LibXML::XML::Parser.string(reponse).parse
    end
    
  end
  
end

require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/airline'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/flight'))
require File.expand_path(File.join(File.dirname(__FILE__), 'flightstats/data_feed'))