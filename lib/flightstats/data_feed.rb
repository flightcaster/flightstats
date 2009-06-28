class FlightStats::DataFeed

  PARSER_OPTIONS = {:options => LibXML::XML::Parser::Options::NOBLANKS}
  
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
      attributes['timestamp'] = Time.parse(attributes['date_time_utc'][0..18]+"+00:00").utc
      attributes.delete('date_time_utc')
      attributes.delete('date_time')
      attributes.each {|key, value| attributes[key] = value.to_i if !key.index('time')}
      @files << attributes
    end
  end
  
  def self.get_gz_file(id)
    id = id['id'] if id.class == Hash
    FlightStats::raw_query({:file=>id}, '/development/feed')
  end
  
  def self.get_file(id)
    Zlib::GzipReader.new(FlightStats::DataFeed.get_gz_file(id))
  end
  
  # passes each file to a block,
  # each file is the raw gzipped file from flightstats, StringIO object
  def each_gz_file(&block)
    if block.arity == 1
      @files.each{ |f| block.call(FlightStats::DataFeed.get_gz_file(f)) }
    elsif block.arity == 2
      @files.each { |f|
        block.call(FlightStats::DataFeed.get_gz_file(f), f['timestamp'])
      }
    end
  end

  # passes each file to a block, each file is a Zlib::GzipReader instance
  def each_file(&block)
    if block.arity == 1
      @files.each{ |f| block.call(FlightStats::DataFeed.get_file(f)) }
    elsif block.arity == 2
      @files.each { |f|
        block.call(FlightStats::DataFeed.get_file(f), f['timestamp'])
      }
    end
  end
        
  # passes each update to a block, each update is an instance of FlightStats::Flight
  def each(&block)
    each_file { |file| FlightStats::DataFeed.process_file(file, &block) }
  end
  
  def self.process_file(file, &block)
    xml = LibXML::XML::Parser.string(file.read, PARSER_OPTIONS).parse.root
    xml.children.each do |node|
      flight = FlightStats::Flight.new(node.children[0])
      time_updated = Time.parse(node.attributes['DateTimeRecorded'][0..18] + ' PT')
      flight.attributes['updated_at'] = time_updated.utc
      block.call(flight)
    end
  end
  
end