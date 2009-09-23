class FlightStats::DataFeed
  
  PATH = '/development/feed'
  
  attr_reader :last_accessed_at
        
  def initialize(time=nil)
    @last_accessed_at = (time || Time.now.utc)
  end
  
  def files(&block)
    params = {:lastAccessed => @last_accessed_at.utc.strftime("%Y-%m-%dT%H:%M"), :useUTC => true}
    parser = LibXML::XML::SaxParser.io(FlightStats.query(params, PATH))
    
    if block_given?
      parser.callbacks = SaxParser.new(&block)
      parser.parse
    else
      files = []
      parser.callbacks = SaxParser.new { |file| files << file }
      parser.parse
      files
    end
  end
    
  # def self.get_gz_file(id)
  #   id = id['id'] if id.class == Hash
  #   FlightStats::raw_query({:file=>id}, '/development/feed')
  # end
  # 
  # def self.get_file(id)
  #   Zlib::GzipReader.new(FlightStats::DataFeed.get_gz_file(id))
  # end
  # 
  # # passes each file to a block,
  # # each file is the raw gzipped file from flightstats, StringIO object
  # def each_gz_file(&block)
  #   if block.arity == 1
  #     @files.each{ |f| block.call(FlightStats::DataFeed.get_gz_file(f)) }
  #   elsif block.arity == 2
  #     @files.each { |f|
  #       block.call(FlightStats::DataFeed.get_gz_file(f), f['timestamp'])
  #     }
  #   end
  # end
  # 
  # # passes each file to a block, each file is a Zlib::GzipReader instance
  # def each_file(&block)
  #   if block.arity == 1
  #     @files.each{ |f| block.call(FlightStats::DataFeed.get_file(f)) }
  #   elsif block.arity == 2
  #     @files.each { |f|
  #       block.call(FlightStats::DataFeed.get_file(f), f['timestamp'])
  #     }
  #   end
  # end
  #       
  # # passes each update to a block, each update is an instance of FlightStats::Flight
  # def each(&block)
  #   each_file { |file| FlightStats::DataFeed.process_file(file, &block) }
  # end
  # 
  # def self.process_file(file, &block)
  #   xml = LibXML::XML::Parser.string(file.read, PARSER_OPTIONS).parse.root
  #   xml.children.each do |node|
  #     flight = FlightStats::Flight.new(node.children[0])
  #     time_updated = Time.parse(node.attributes['DateTimeRecorded'][0..18] + ' PT')
  #     flight.attributes['updated_at'] = time_updated.utc
  #     block.call(flight)
  #   end
  # end
  # 
end