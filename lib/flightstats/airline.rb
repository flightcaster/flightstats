class FlightStats::Airline
  
  attr_accessor :flightstats_code, :iata_code, :icao_code, :faa_code, :name
  
  class << self
  
    def find_by_icao_code(code)
      params = { 'Service' => 'AirlineGetAirlinesService',
        'airlineGetAirlinesInfo.airline.icaoCode' => code.upcase}
      fetch_from_flightstats(params)
    end
    
    def parse(xml)
      node = xml.class == LibXML::XML::Node ? xml : xml.root.child
      
      FlightStats::Airline.new do |a|
        a.iata_code = node.attributes['IATACode']
        a.icao_code = node.attributes['ICAOCode']
        a.faa_code  = node.attributes['FAACode']
        a.flightstats_code = node.attributes['AirlineCode']
        a.name = node.attributes['Name']
      end
    end
    
  end
  
  def initialize(attributes=nil)
    if attributes
      attributes.each_pair do |key, value|
        instance_variable_set(('@' + key.to_s).to_sym.to_s,value)
      end
    end
    result = yield self if block_given?
  end  
   
  private
  
    def self.fetch_from_flightstats(params)
      parse(FlightStats.query(params))    
    end
  
end