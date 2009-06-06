class FlightStats::DataFeed
  
  attr_accessor :last_accessed, :files
  
  def initialize(time=nil)
    @last_accessed = (time || Time.now)
    @files = []
    init_file_list
  end
  
  def init_file_list
    params = {:lastAccessed => @last_accessed.utc.strftime("%Y-%m-%dT%H:%M"), 
              :useUTC => true}
    FlightStats.query(params, '/development/feed').root.children.each do |child|
      attributes = child.attributes.to_h.underscore_keys
      attributes['date_time'] = attributes['date_time_utc']
      attributes.delete('date_time_utc')
      attributes.each {|key, value| attributes[key] = value.to_i if !key.index('time')}
      attributes['url'] = FlightStats::query_url({:file=>attributes['id']}, '/development/feed')
      @files << attributes
    end
  end
      
  def updates
    @files.each do |file|
      file = Zlib::GzipReader.new( open(file['url']) )
      parser_options = {:options => LibXML::XML::Parser::Options::NOBLANKS}
      xml = LibXML::XML::Parser.string(file.read, parser_options).parse.root
      xml.children.each do |child|
        flight = FlightStats::Flight.new(child.children[0])
        time_updated = Time.parse(child.attributes['DateTimeRecorded'][0..18] + ' PT')
        flight.attributes['time_updated'] = time_updated.utc
        yield(flight, child)
      end
    end
  end
    
end