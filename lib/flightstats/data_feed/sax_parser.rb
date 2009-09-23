class FlightStats::DataFeed::SaxParser

  include LibXML::XML::SaxParser::Callbacks

  def initialize(&on_file_block)
    @on_file_block = on_file_block
  end
    
  def on_start_element_ns(name, attributes, prefix, uri, namespaces)
    case name
    when 'File'
      file = FlightStats::DataFeed::File.new
      file.id = attributes['ID']
      file.message_count = attributes['Messages'].to_i
      file.bytes = attributes['Bytes'].to_i
      file.timestamp = Time.utc( attributes['DateTimeUTC'][0..3],
                                 attributes['DateTimeUTC'][5..6],
                                 attributes['DateTimeUTC'][8..9],
                                 attributes['DateTimeUTC'][11..12],
                                 attributes['DateTimeUTC'][14..15],
                                 attributes['DateTimeUTC'][17..18],
                                 attributes['DateTimeUTC'][20..22])
      @on_file_block.call(file)
    end
  end
  
end