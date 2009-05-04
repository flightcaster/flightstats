class FlightStats::WeatherReport
  
  attr_accessor :zone, :date, :cities, :counties, :forecast, :estimates,
                :general_information, :header
  
  class << self
  
    def find_by_zone(weather_forecast_zone)
      params = { 'Service' => 'WeatherForecastGetForecastService',
      'weatherForecastZone.zone' => weather_forecast_zone.upcase }
      fetch_from_flightstats(params)
    end
    
    def parse(xml)
      node = (xml.class == LibXML::XML::Node ? xml : xml.root.child)
      
      FlightStats::WeatherReport.new do |report|
        report.date = DateTime.parse(node.attributes['Date'])
        report.zone = node.attributes['Zone']
        report.general_information = node.attributes['General']
        report.header = node.attributes['Header']
        node.children.each do |e|
          case e.name
          when 'City' then report.cities << e.content.strip
          when 'County' then report.counties << e.content.strip
          when 'WeatherDayForecast' then report.forecast << parse_forecast(e)
          when 'WeatherCityEstimate' then report.estimates << parse_city_estimate(e)
          end
        end
      end
    end
    
  end
  
  def initialize(attributes=nil)
    @cities = []
    @counties = []
    @forecast = []
    @estimates = []
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
    
    def self.parse_forecast(node)
      f = {:day => node.attributes['Day'],
           :start_time => node.attributes['StartTime'],
           :end_time => node.attributes['EndTime'],
           :forecast => []}
      node.children.each { |e| f[:forecast] << e.content.strip! if e.name == "Forecast" }
      f
    end
    
    def self.parse_city_estimate(node)
      f = {:city => node.attributes['City'],
           :estimate => []}
      node.children.each do |e|
        if e.name == "Estimate"
          f[:estimate] << {:date => DateTime.parse(e.attributes['Date']),
                           :rain_precentage => e.attributes['RainPercentage'],
                           :temperature => e.attributes['Temperature']}
        end
      end
      f
    end
  
end