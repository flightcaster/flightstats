class FlightStats::DataFeed
  
  attr_reader :last_accessed, :files
  
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
      @files << attributes
    end
  end
  
  # passes each file to a block,
  # each file is the raw gzipped file from flightstats, StringIO object
  def each_gz_file
    @files.each do |file|
      yield( FlightStats::raw_query({:file=>file['id']}, '/development/feed') )
    end
  end

  # passes each file to a block, each file is a Zlib::GzipReader instance
  def each_file
    each_gz_file { |gz_file| yield( Zlib::GzipReader.new(gz_file) ) }
  end
      
  # passes each update to a block, each update is an instance of FlightStats::Flight
  def each
    parser_options = {:options => LibXML::XML::Parser::Options::NOBLANKS}
    each_file do |file|
      xml = LibXML::XML::Parser.string(file.read, parser_options).parse.root
      xml.children.each do |node|
        flight = FlightStats::Flight.new(node.children[0])
        time_updated = Time.parse(node.attributes['DateTimeRecorded'][0..18] + ' PT')
        flight.attributes['updated_at'] = time_updated.utc
        yield(flight)
      end
    end
  end
    
end