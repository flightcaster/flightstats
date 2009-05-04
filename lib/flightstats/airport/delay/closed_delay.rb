class FlightStats::Airport::ClosedDelay < FlightStats::Airport::Delay
  
  attr_accessor :start_time, :end_time
  
  class << self
    
    def parse(xml)
      node = xml.class == LibXML::XML::Node ? xml : xml.root.child
      
      FlightStats::Airport::ClosedDelay.new do |a|
        a.description = node.attributes['Description']
        a.reason = node.attributes['Reason']
        a.start_time = DateTime.parse(node.attributes['StartTime'])
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