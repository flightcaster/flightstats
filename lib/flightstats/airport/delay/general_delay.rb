class FlightStats::Airport::GeneralDelay < FlightStats::Airport::Delay
  
  attr_accessor :min_time, :max_time, :trend
  
  class << self
    
    def parse(xml)
      node = xml.class == LibXML::XML::Node ? xml : xml.root.child
      
      FlightStats::Airport::GeneralDelay.new do |a|
        a.description = node.attributes['Description'],
        a.reason = node.attributes['Reason'],
        a.min_time = node.attributes['MinTime'].to_i,
        a.max_time = node.attributes['MaxTime'].to_i
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