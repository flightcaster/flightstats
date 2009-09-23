require 'uri'
require 'net/https'
require 'zlib'
require 'libxml'
require 'time'
require 'tzinfo'

module FlightStats
  SERVER = "https://www.pathfinder-xml.com"
  PATH = "/development/xml"
  
  class << self
    def authentication_token
      {'login.guid' => FLIGHTSTATS_GUID}
    end
    
    def uri(params, path = nil)
      params.merge!(authentication_token)
      URI.parse(SERVER + (path || PATH) + '?' + params.collect{ |k,v| "#{k}=#{v}"}.join('&'))
    end

    def query(params, path = nil)
      url = uri(params, path)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      body = http.request_get(url.path+'?'+url.query) { |response|
        if response.is_a?(Net::HTTPSuccess)
          return StringIO.new(response.read_body)
        else
          raise StandardError, response.read_body
        end
      }
    end
  end
  
end

require 'flightstats/airline'

require 'flightstats/flight'
require 'flightstats/flight/codeshare'

require 'flightstats/data_feed'
require 'flightstats/data_feed/sax_parser'
require 'flightstats/data_feed/file'
require 'flightstats/data_feed/file/sax_parser'
require 'flightstats/data_feed/file/flight_update'
