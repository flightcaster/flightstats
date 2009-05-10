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
  attr_accessor :codeshares, :origin_airport, :destination_airport,
                :diverted_airport, :airline
  
  def initialize(attributes_or_xml=nil)
    @codeshares = []
    case attributes_or_xml
    when LibXML::XML::Document, LibXML::XML::Node
      parse_flightstats_xml(attributes_or_xml)
    when Hash
      @attributes = attributes_or_xml.class
    else
      @attributes = Hash.new
    end
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
    
    def get(airline_icao_code, flight_number, depatring_date=nil)
      depatring_date ||= Date.today
      params = { QUERY_OPTIONS[:departure_date_min] => "#{depatring_date.strftime('%Y-%m-%d')}T00:00",
        QUERY_OPTIONS[:departure_date_max] => "#{depatring_date.strftime('%Y-%m-%d')}T24:00",
        QUERY_OPTIONS[:icao_code] => airline_icao_code.upcase,
        QUERY_OPTIONS[:flight_number] => flight_number }.merge(QUERY_PARAMS)
      FlightStats::Flight.new(FlightStats.query(params))
    end
    
  end
  
  def parse_flightstats_xml(xml)
    node = (xml.class == LibXML::XML::Node ? xml : xml.root.child)
    return nil if node == nil
    
    @attributes = node.attributes.to_h.underscore_keys
    
    @attributes.each_pair do |key, value|
      case key
      when 'flight_number', /number/, /air_time/, /block_time/
        @attributes[key] = value.to_i
      when /date/i, /(estimated|scheduled).+(departure|arrival)/i
        @attributes[key] = DateTime.parse(value)
      end
    end
    
    node.children.each do |e|
      case e.name
      when 'FlightHistoryCodeshare' then codeshares << parse_code_share(e)
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