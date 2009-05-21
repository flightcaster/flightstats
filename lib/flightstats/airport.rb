class FlightStats::Airport
  
  AGGREGATE_PARAMS = {
    'airportGetAirportsInfo.airportGetAirportsRequestedData.aggregatedAirports' => 'true'
  }
  
  EXACT_QUERY_OPTIONS = {
    :icao_code => "airportGetAirportsInfo.airport.icaoCode",
    :iata_code => "airportGetAirportsInfo.airport.iataCode",
    :faa_code => "airportGetAirportsInfo.airport.faaCode",
    :name => "airportGetAirportsInfo.airport.name"
  }
  
  EXACT_QUERY_PARAMS = { 'Service' => 'AirportGetAirportsService' }
  
  class << self
    
    # Find :exact, :matching, :region
    def get(query_type, options)
      case query_type
      when :exact
        get_exact(options)
      else
        raise "Unrecognized Query Type"
      end
    end
    
    def get_exact(options)
      params = convert_to_params(EXACT_QUERY_PARAMS, EXACT_QUERY_OPTIONS, options)
      FlightStats::Airport.new(FlightStats.query(params))
    end
    
    # converts the options (eg. :icao_code => "KBOS") to the respective representation
    # on flightstats. Provide the options and the kind of params that you wish to merge
    # eg.
    # 
    #   convert_to_params(FLIGHTSTATS_EXACT_QUERY_PARAMS, FLIGHTSTATS_EXACT_QUERY_OPTIONS, {:icao_code => "KBOS"})
    # 
    # will result in the params that need to be passed to flightstats for an exact 
    # query against their api.
    # 
    # Note that the :aggregate is set to true by default, if the information is not wanted
    # set :aggregate to false
    def convert_to_params(required_params, optional_params, options)
      params = required_params.dup
      params.merge!(AGGREGATE_PARAMS) unless options[:aggregate] == false
      options.each_pair do |key, value|
        params[optional_params[key]] = value.to_s
      end
      params
    end
    
  end
  
  
  # A hash that stores the attributes of the model. This may include:
  #   icao_code
  #   iata_code
  #   faa_code
  #   name
  #   longitude
  #   latitude
  #   hub
  #   weather_zone
  #   street
  #   state_code
  #   country_code
  #   postal_code
  attr_accessor :attributes
  
  attr_accessor :metar, :weather_forecast, :closed_delays, :general_arrival_delays,
                :general_departure_delays, :ground_delays, :ground_stop_delays
  
  # initializes based on either a Lib::XML::Document given or a attributes hash
  def initialize(attributes_or_xml=nil)
    @metar = []
    @weather_forecast = []
    @closed_delays = []
    @general_arrival_delays = []
    @general_departure_delays = []
    @ground_delays = []
    @ground_stop_delays = []
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
    node = (xml.class == LibXML::XML::Node ? xml : xml.root.child)
    return nil if node == nil
    
    @attributes = node.attributes.to_h.underscore_keys
    @attributes['hub'] = @attributes.delete('is_major_airport')
    @attributes['street'] = (@attributes.delete('street1').to_s + "\n" +
                            @attributes.delete('street2').to_s).strip
    
    # TODO: do something with the child elements
    node.children.each do |e|
     case e.name
     when 'MetarReport'
       metar = FlightStats::METAR.new(e)
     when 'WeatherForecast'
       weather_forecast = FlightStats::WeatherForecast.new(e)
     when 'ClosedDelay'
       closed_delays << FlightStats::Delays::ClosedDelay.parse(e, a.icao_code)
     when 'GeneralArrivalDelay'
       general_arrival_delays << FlightStats::Airport::GeneralArrivalDelay.parse(e)
     when 'GeneralDepartureDelay'
       general_departure_delays << FlightStats::Airport::GeneralDepartureDelay.parse(e)
     when 'GroundDelay'
       ground_delays << FlightStats::Airport::GroundDelay.parse(e)
     when 'GroundStopDelay'
       ground_stop_delays << FlightStats::Airport::GroundStopDelay.parse(e)
     end
    end
  end
  
  def method_missing(method_name, *args, &block)
    method_name = method_name.to_s
    if method_name =~ /=$/ && attributes[method_name[0..-2]]
      attributes[method_name[0..-2]] = args
    elsif attributes[method_name]
      attributes[method_name]
    else
      raise NoMethodError
    end
  end
  
  def self.arrivals(code, depatring_date=nil)
    depatring_date ||= Date.today
    flights = []

    params = {'Service' => 'FlightHistoryGetRecordsService',
              'info.specificationArrivals[0].airport.icaoCode' => code.upcase,
              'info.specificationDateRange.arrivalDateTimeMin' => "#{depatring_date.strftime('%Y-%m-%d')}T00:00",
              'info.specificationDateRange.arrivalDateTimeMax' => "#{depatring_date.strftime('%Y-%m-%d')}T24:00",
              'info.specificationFlights[0].searchCodeshares' => 'false'}
    xml_doc = FlightStats.query(params)
    xml_doc.root.children.each do |child|
      flights << FlightStats::Flight.new(child)
    end
    flights
  end

  def self.departures(code, depatring_date=nil)
    depatring_date ||= Date.today
    flights = []

    params = {'Service' => 'FlightHistoryGetRecordsService',
              'info.specificationDepartures[0].airport.icaoCode' => code.upcase,
              'info.specificationDateRange.departureDateTimeMin' => "#{depatring_date.strftime('%Y-%m-%d')}T00:00",
              'info.specificationDateRange.departureDateTimeMax' => "#{depatring_date.strftime('%Y-%m-%d')}T24:00",
              'info.specificationFlights[0].searchCodeshares' => 'false'}
    xml_doc = FlightStats.query(params)
    xml_doc.root.children.each do |child|
      flights << FlightStats::Flight.new(child)
    end
    flights
  end
  
end
