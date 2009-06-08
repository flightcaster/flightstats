class FlightStats::Airline
  
  attr_accessor :attributes
  
  # initializes based on either a Lib::XML::Document given or a attributes hash
  def initialize(attributes_or_xml=nil)
    case attributes_or_xml
    when LibXML::XML::Document, LibXML::XML::Node
      parse_flightstats_xml(attributes_or_xml)
    else
      @attributes = Hash.new
    end
  end

  # TODO: parse the contact infomration
  def parse_flightstats_xml(xml)
    node = xml.class == LibXML::XML::Node ? xml : xml.root.child
    return nil if node == nil
  
    case node.name
    when "Error"
      raise node.children[0].content
    when "AirlineDetail"
      # TODO: this needs to be changed to parse airline details
    when "Airline"
      @attributes = node.attributes.to_h.underscore_keys
      flightstats_code = @attributes.delete('airline_code')
      if @attributes['icao_code'] == nil and flightstats_code.size == 3
        @attributes['icao_code'] = flightstats_code
      end
      if @attributes['iata_code'] == nil and flightstats_code.size == 2
        @attributes['iata_code'] = flightstats_code
      end
    end
    
  end
end