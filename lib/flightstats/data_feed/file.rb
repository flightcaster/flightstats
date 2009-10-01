class FlightStats::DataFeed::File
  
  attr_accessor :id, :message_count, :bytes, :timestamp
  alias :size :bytes
  
  def initialize(content = nil)
    @content = content if content.is_a?(StringIO) or content.is_a?(File)
  end
  
  def content
    if @content.nil?
      @content = FlightStats.query({:file => @id}, FlightStats::DataFeed::PATH)
    end
    @content
  end
  
  def updates(&block)
    parser = LibXML::XML::SaxParser.io(Zlib::GzipReader.new(content))
    
    if block_given?
      parser.callbacks = SaxParser.new(&block)
      parser.parse
    else
      updates = []
      parser.callbacks = SaxParser.new { |update| updates << update }
      parser.parse
      updates
    end
  end
  
end