class FlightStats::Airline
  
  attr_accessor :attributes
  
  EXACT_QUERY_OPTIONS = {
    :icao_code => 'airlineGetAirlinesInfo.airline.icaoCode',
    :iata_code => 'airlineGetAirlinesInfo.airline.iataCode',
    :flightstats_code => 'airlineGetAirlinesInfo.airline.airlineCode',
    :details => 'airlineGetAirlinesInfo.airlineGetAirlinesRequestedData.airlineDetails'
  }
  
  QUERY_PARAMS = {
    'Service' => 'AirlineGetAirlinesService'
  }
  
  class << self
    
    # Find :exact, :matching, :region
    def get(query_type, options)
      options[:details] ||= true
      case query_type
      when :exact
        get_exact(options)
      else
        raise "Unrecognized Query Type"
      end
    end
    
    def get_exact(options)
      params = convert_to_params(QUERY_PARAMS, EXACT_QUERY_OPTIONS, options)
      FlightStats::Airline.new(FlightStats.query(params))
    end
    
    # converts the options (eg. :icao_code => "KBOS") to the respective representation
    # on flightstats. Provide the options and the kind of params that you wish to merge
    # eg.
    # 
    #   convert_to_params(FLIGHTSTATS_EXACT_QUERY_PARAMS, FLIGHTSTATS_EXACT_QUERY_OPTIONS, {:icao_code => "KBOS"})
    # 
    # will result in the params that need to be passed to flightstats for an exact 
    # query against their api.
    # 
    # Note that the :aggregate is set to true by default, if the information is not wanted
    # set :aggregate to false
    def convert_to_params(required_params, optional_params, options)
      params = required_params.dup
      options.each_pair do |key, value|
        params[optional_params[key]] = value.to_s
      end
      params
    end
    
  end
  
  # initializes based on either a Lib::XML::Document given or a attributes hash
  def initialize(attributes_or_xml=nil)
    case attributes_or_xml
    when LibXML::XML::Document, LibXML::XML::Node
      parse_flightstats_xml(attributes_or_xml)
    when Hash
      @attributes = attributes_or_xml.class
    else
      @attributes = Hash.new
    end
  end
  
  # TODO: parse the contact infomration
  def parse_flightstats_xml(xml)
    node = xml.class == LibXML::XML::Node ? xml : xml.root.child
    return nil if node == nil
    
    node = node.child if node.name == "AirlineDetail" # this needs to be changed to parse airline details
    
    puts node.attributes.to_h
    puts node.attributes.to_h.underscore_keys
    @attributes = node.attributes.to_h.underscore_keys
    @attributes['flightstats_code'] = @attributes.delete('airline_code')
  end
  
end