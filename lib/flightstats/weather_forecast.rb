class FlightStats::WeatherForecast
  
  attr_accessor :attributes
  
  QUERY_OPTIONS = {
    :weather_zone => 'weatherForecastZone.zone'
  }
  
  QUERY_PARAMS = {
    'Service' => 'WeatherForecastGetForecastService'
  }
  
  class << self
    
    # Gets the weather forecast gvien the weather code
    #   FlightStats::WeatherReport.get("ORZ006")
    def get(weather_code)
      params = { QUERY_OPTIONS[:weather_zone] => weather_code }
      params.merge!(QUERY_PARAMS)
      FlightStats::WeatherForecast.new(FlightStats.query(params))
    end
    
  end
  
  # initializes based on either a Lib::XML::Document given or a attributes hash
  def initialize(attributes_or_xml=nil)
    case attributes_or_xml
    when LibXML::XML::Document, LibXML::XML::Node
      parse_flightstats_xml(attributes_or_xml)
    when Hash
      @attributes = attributes_or_xml.class
    else
      @attributes = Hash.new
    end
  end
  
  def parse_flightstats_xml(xml)
    node = xml.class == LibXML::XML::Node ? xml : xml.root.child
    return nil if node == nil
    
    @attributes = node.attributes.to_h.underscore_keys
    @attributes['date'] = DateTime.parse(@attributes['date'])
    @attributes['general_information'] = @attributes.delete('General')
    
    @attributes['cities'] = []
    @attributes['counties'] =[]
    @attributes['forecast'] = []
    @attributes['estimates'] = []
    node.children.each do |e|
      case e.name
      when 'City' then @attributes['cities'] << e.content.strip
      when 'County' then @attributes['counties'] << e.content.strip
      when 'WeatherDayForecast' then @attributes['forecast'] << parse_forecast(e)
      when 'WeatherCityEstimate' then @attributes['estimates'] << parse_city_estimate(e)
      end
    end
  end
  
  def parse_forecast(node)
    f = {'day' => node.attributes['Day'],
         'start_time' => node.attributes['StartTime'],
         'end_time' => node.attributes['EndTime'],
         'forecast' => []}
    node.children.each { |e| f['forecast'] << e.content.strip! if e.name == "Forecast" }
    f
  end

  def parse_city_estimate(node)
    f = {'city' => node.attributes['City'].strip,
         'estimate' => []}
    node.children.each do |e|
      if e.name == "Estimate"
        f['estimate'] << {'date' => DateTime.parse(e.attributes['Date']),
                         'rain_precentage' => e.attributes['RainPercentage'].strip,
                         'temperature' => e.attributes['Temperature'].strip}
      end
    end
    f
  end
  
end