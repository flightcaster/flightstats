class FlightStats::Flight
  
  AGGREGATE_PARAMS = {
    'info.flightHistoryGetRecordsRequestedData.aggregatedAirports' => 'true',
    'info.specificationFlights[0].searchCodeshares' => 'true'
  }
  
  QUERY_OPTIONS = {
    :departure_date_min => 'info.specificationDateRange.departureDateTimeMin',
    :departure_date_max => 'info.specificationDateRange.departureDateTimeMax',
    :icao_code => 'info.specificationFlights[0].airline.icaoCode',
    :flight_number => 'info.specificationFlights[0].flightNumber'
  }
  
  QUERY_PARAMS = { 'Service' => 'FlightHistoryGetRecordsService' }
  
  attr_accessor :attributes
  attr_accessor :origin_airport, :destination_airport,
                :diverted_airport, :airline
  
  def initialize(attributes_or_xml=nil)
    case attributes_or_xml
    when LibXML::XML::Document, LibXML::XML::Node
      parse_flightstats_xml(attributes_or_xml)
    when Hash
      @attributes = attributes_or_xml.class
    else
      @attributes = Hash.new
    end
    @attributes['codeshares'] ||= []
    result = yield self if block_given?
  end
  
  def origin_airport
    @origin_airport ||= FlightCaster::Airport.find_by_icao_code(:origin_icao_code)
  end
  
  def destination_airport
    @destination_airport ||= FlightCaster::Airport.find_by_icao_code(:destination_airport)
  end
  
  def diverted_airport
    @diverted_airport ||= FlightCaster::Airport.find_by_icao_code(:diverted_airport)
  end
  
  class << self
    
    # Returns an array of results. Searching for a flight by the icao and flight number results in 
    # 1 to many results from the api
    def get(airline_icao_code, flight_number, depatring_date=nil)
      depatring_date ||= Date.today
      params = { QUERY_OPTIONS[:departure_date_min] => "#{depatring_date.strftime('%Y-%m-%d')}T00:00",
        QUERY_OPTIONS[:departure_date_max] => "#{depatring_date.strftime('%Y-%m-%d')}T24:00",
        QUERY_OPTIONS[:icao_code] => airline_icao_code.upcase,
        QUERY_OPTIONS[:flight_number] => flight_number }.merge(QUERY_PARAMS)
      results = []
      FlightStats.query(params).root.each do |node|
        if node.name == "FlightHistory"
          results << FlightStats::Flight.new(node)
        end
      end
      results
    end
    
    def get_updates(time=nil)
      updates = []
      files = get_updates_file_list(time)
      files.each do |f|
        file = open("http://www.pathfinder-xml.com/development/feed?login.guid=#{FLIGHTSTATS_GUID}&file=#{f[:id]}")
        xml = LibXML::XML::Parser.string(Zlib::GzipReader.new(file).read).parse
        xml.root.children.each do |child|
          if child.name != 'text'
            timestamp = DateTime.parse(child.attributes['DateTimeRecorded'])
            f = FlightStats::Flight.new(child.children[0])
            f.attributes['timestamp'] = timestamp
            updates << f
          end
        end
      end
      updates
    end
    
    def get_updates_file_list(time=nil)
      time ||= (Time.now - 60)
      http = Net::HTTP.new("www.pathfinder-xml.com", 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      reponse = http.get("/development/feed?lastAccessed=#{time.utc.strftime("%Y-%m-%dT%H:%M")}&useUTC=true&login.guid=#{FLIGHTSTATS_GUID}").body
      xml = LibXML::XML::Parser.string(reponse).parse
      files = []
      xml.root.children.each do |child|
        if child['DateTimeUTC'][0..15] != time.utc.strftime("%Y-%m-%dT%H:%M")
          files << {:id => child['ID'], :date => child['DateTimeUTC'][0..15]}
        end
      end
      files
    end
  end
  
  def parse_flightstats_xml(xml)
    node = (xml.class == LibXML::XML::Node ? xml : xml.root.child)
    return nil if node == nil

    @attributes = {'codeshares' => []}
    
    node.attributes.to_h.underscore_keys.each_pair do |key, value|
      case key
      when 'flight_number'
        @attributes['number'] = value.to_i
      when 'flight_history_id'
        @attributes['history_id'] = value
      when /date/i, /(estimated|scheduled).+(departure|arrival)/i
        @attributes[key.gsub(/_date$/,"")+'_time'] = DateTime.parse(value)
      when /number/, /air_time/, /block_time/
        @attributes[key] = value.to_i
      else
        @attributes[key] = value if !(key =~ /(arrival|departure|diverted)_airport_time_zone_offset/)
      end
    end
    
    node.children.each do |e|
      case e.name
      when 'FlightHistoryCodeshare' then @attributes['codeshares'] << parse_code_share(e)
      when 'Airline' 
        @attributes['airline_icao_code'] = e.attributes['ICAOCode']
        airline = FlightStats::Airline.new(e)
      when 'Origin' then @attributes['origin_icao_code'] = e.attributes['ICAOCode']
      when 'Destination' then @attributes['destination_icao_code'] = e.attributes['ICAOCode']
      when 'Diverted' then @attributes['diverted_icao_code'] = e.attributes['ICAOCode']
      end
    end
    
    node.children[1..-1].each do |e|
      if e.name == "AggregatedAirport"
        port = FlightStats::Airport.parse(e)
        if port.icao_code == @attributes['destination_icao_code']
          port.timezone_offset = node.attributes['ArrivalAirportTimeZoneOffset']
          destination_airport = port
        elsif port.icao_code == @attributes['origin_icao_code']
          port.timezone_offset = node.attributes['DepartureAirportTimeZoneOffset']
          origin_airport = port
        elsif port.icao_code == @attributes['diverted_icao_code']
          port.timezone_offset = node.attributes['DivertedAirportTimeZoneOffset']
          diverted_airport = port
        end
      end
    end
    
  end

  def parse_code_share(xml)
    { :designator => xml.attributes['Designator'],
      :airline_icao => xml.children[0].attributes['ICAOCode'],
      :number => xml.attributes['FlightNumber'] }
  end
  
end