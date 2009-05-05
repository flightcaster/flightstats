class FlightStats::Airport::GroundStopDelay < FlightStats::Airport::Delay
  
  attr_accessor :end_time
  
  class << self

    def parse(xml)
      node = xml.class == LibXML::XML::Node ? xml : xml.root.child
      return nil if node == nil

      FlightStats::Airport::GroundStopDelay.new do |a|
        a.airport_icao = airport_icao
        a.description = node.attributes['Description']
        a.reason = node.attributes['Reason']
        a.end_time = DateTime.parse(node.attributes['EndTime'])
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