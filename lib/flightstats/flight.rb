class FlightStats::Flight
  attr_accessor :attributes,
                :airline
                
  def initialize(attributes_or_xml=nil)
    case attributes_or_xml
    when LibXML::XML::Document, LibXML::XML::Node
      parse_flightstats_xml(attributes_or_xml)
    else
      @attributes = Hash.new
    end
    @attributes['codeshares'] ||= []
    result = yield self if block_given?
  end
  
  def parse_time(key, value, attributes)
    year, month, day = value[0..3], value[5..6], value[8..9]
    hour, min, sec = value[11..12], value[14..15], value[17..18]
    if key =~ /arrival/i
      if attributes['diverted_airport_time_zone_offset']
        tz = attributes['diverted_airport_time_zone_offset'].to_i
      else
        tz = attributes['arrival_airport_time_zone_offset'].to_i
      end
    else
      tz = attributes['departure_airport_time_zone_offset'].to_i
    end
    sign = tz < 0 ? "-" : "+"
    tz = tz.abs
    tz = "0#{tz}" if tz < 10
    Time.parse("#{year}-#{month}-#{day}T#{hour}:#{min}:#{sec}#{sign}#{tz}:00").utc
  end
  
  def parse_code_share(xml)
    { :designator => xml.attributes['Designator'],
      :airline_icao => xml.children[0].attributes['ICAOCode'],
      :number => xml.attributes['FlightNumber'] }
  end
  
  def parse_flightstats_xml(xml)
    node = (xml.class == LibXML::XML::Node ? xml : xml.root.child)
    return nil if node == nil

    @attributes = {'codeshares' => []}
    
    xml_attributes = node.attributes.to_h.underscore_keys
    xml_attributes.each_pair do |k, v|
      case k
      when /date/i
        @attributes[k.gsub(/_date$/,"")+'_time'] = parse_time(k, v, xml_attributes)
      when /number/, /air_time/, /block_time/, /flight_(number|history_id)/, /time_zone_offset/
        @attributes[k.sub('flight_','')] = v.to_i
      else
        @attributes[k] = v
      end
    end
    
    node.children.each do |e|
      case e.name
      when 'FlightHistoryCodeshare' then @attributes['codeshares'] << parse_code_share(e)
      when 'Airline'
        @airline = FlightStats::Airline.new(e)
        @attributes['airline_iata_code'] = @airline.attributes['iata_code'] if @airline.attributes['iata_code']
        @attributes['airline_icao_code'] = @airline.attributes['icao_code'] if @airline.attributes['icao_code']
      when 'Origin' then @attributes['origin_icao_code'] = e.attributes['ICAOCode']
      when 'Destination' then @attributes['destination_icao_code'] = e.attributes['ICAOCode']
      when 'Diverted' then @attributes['diverted_icao_code'] = e.attributes['ICAOCode']
      end
    end
    
    # TODO Aggregated Data  
  end
  
end