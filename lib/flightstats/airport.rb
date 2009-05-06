class FlightStats::Airport
  
  attr_accessor :flightstats_code, :iata_code, :icao_code, :faa_code, :name,
                :street, :city, :state, :postal_code, :country, :latitude,
                :longitude, :hub, :weather_station_code, :weather_zone,
                :timezone_offset
  
  attr_accessor :closed_delays, :general_arrival_delays,
                :general_departure_delays, :ground_delays, :ground_stop_delays
                
  attr_accessor :weather_report, :metar_report
  
  class << self
  
    def find_by_icao_code(code)
      params = {'Service' => 'AirportGetAirportsService',
                'airportGetAirportsInfo.airport.icaoCode' => code.upcase,
                'airportGetAirportsInfo.airportGetAirportsRequestedData.aggregatedAirports' => 'true'}
      fetch_from_flightstats(params)
    end
    
    def arrivals(code, depatring_date=nil)
      depatring_date ||= Date.today
      flights = []

      params = {'Service' => 'FlightHistoryGetRecordsService',
                'info.specificationArrivals[0].airport.icaoCode' => code.upcase,
                'info.specificationDateRange.arrivalDateTimeMin' => "#{depatring_date.strftime('%Y-%m-%d')}T00:00",
                'info.specificationDateRange.arrivalDateTimeMax' => "#{depatring_date.strftime('%Y-%m-%d')}T24:00"}
      xml_doc = FlightStats.query(params)
      xml_doc.root.children.each do |child|
        flights << FlightStats::Flight.parse(child)
      end
      flights
    end

    def departures(code, depatring_date=nil)
      depatring_date ||= Date.today
      flights = []

      params = {'Service' => 'FlightHistoryGetRecordsService',
                'info.specificationDepartures[0].airport.icaoCode' => code.upcase,
                'info.specificationDateRange.departureDateTimeMin' => "#{depatring_date.strftime('%Y-%m-%d')}T00:00",
                'info.specificationDateRange.departureDateTimeMax' => "#{depatring_date.strftime('%Y-%m-%d')}T24:00"}
      xml_doc = FlightStats.query(params)
      xml_doc.root.children.each do |child|
        flights << FlightStats::Flight.parse(child)
      end
      flights
    end
    
    def parse(xml)
      node = xml.class == LibXML::XML::Node ? xml : xml.root.child
      return nil if node == nil

      FlightStats::Airport.new do |a|
        a.iata_code = node.attributes['IATACode']
        a.icao_code = node.attributes['ICAOCode']
        a.faa_code = node.attributes['FAACode']
        a.flightstats_code = node.attributes['AirportCode']
        a.name = node.attributes['Name']
        a.street = node.attributes['Street1'].to_s + "\n" + node.attributes['Street2'].to_s
        a.city = node.attributes['City']
        a.state = node.attributes['StateCode']
        a.postal_code = node.attributes['PostalCode']
        a.country = node.attributes['CountryCode']
        a.latitude = node.attributes['Latitude'].to_f
        a.longitude = node.attributes['Longitude'].to_f
        a.hub = (node.attributes['IsMajorAirport'] == 'true')
        a.weather_station_code = node.attributes['WeatherStationCode']
        a.weather_zone = node.attributes['WeatherZone']
        
        node.children.each do |e|
          case e.name
          when 'MetarReport'
            a.metar_report = FlightStats::MetarReport.parse(e)
          when 'WeatherForecast'
            a.weather_report = FlightStats::WeatherReport.parse(e)
          when 'ClosedDelay'
            a.closed_delays << FlightStats::Delays::ClosedDelay.parse(e, a.icao_code)
          when 'GeneralArrivalDelay'
            a.general_arrival_delays << FlightStats::Airport::GeneralArrivalDelay.parse(e)
          when 'GeneralDepartureDelay'
            a.general_departure_delays << FlightStats::Airport::GeneralDepartureDelay.parse(e)
          when 'GroundDelay'
            a.ground_delays << FlightStats::Airport::GroundDelay.parse(e)
          when 'GroundStopDelay'
            a.ground_stop_delays << FlightStats::Airport::GroundStopDelay.parse(e)
          end
        end
        
      end
      
    end
    
  end
  
  def arrivals(code, depatring_date=nil)
    FlightStats::Airport.arrivals(icao_code, depatring_date)
  end
  
  def departures(code, depatring_date=nil)
    FlightStats::Airport.departures(icao_code, depatring_date)
  end
  
  def initialize(attributes=nil)
    @closed_delays = Array.new
    @general_arrival_delays = Array.new
    @general_departure_delays = Array.new
    @ground_delays = Array.new
    @ground_stop_delays = Array.new
    if attributes
      attributes.each_pair do |key, value|
        instance_variable_set(('@' + key.to_s).to_sym.to_s,value)
      end
    end
    result = yield self if block_given?
  end  
  
  def to_h
    { :flightstats_code => flightstats_code, 
      :iata_code => iata_code,
      :icao_code => icao_code,
      :faa_code => faa_code,
      :name => name,
      :street => street,
      :city => city,
      :state => state,
      :postal_code => postal_code,
      :country => country,
      :latitude => latitude,
      :longitude => longitude,
      :hub => hub,
      :weather_station_code => weather_station_code,
      :weather_zone => weather_zone,
      :timezone_offset => timezone_offset
    }
  end
  
  private

    def self.fetch_from_flightstats(params)
      parse(FlightStats.query(params))    
    end

end