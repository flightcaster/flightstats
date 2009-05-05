class FlightStats::Flight
  
  attr_accessor :airline_icao_code, :number, :departure_date, :arrival_date,
                :history_id, :status, :status_code, :creator_code,
                :departure_gate, :departure_terminal, :arrival_gate,
                :arrival_terminal, :baggage_claim, :tail_number, :codeshares,
                :published_departure_date, :published_arrival_date,
                :scheduled_gate_departure, :scheduled_gate_arrival,
                :scheduled_runway_departure, :scheduled_runway_arrival,
                :scheduled_air_time, :scheduled_block_time,
                :scheduled_aircraft_type, :estimated_gate_departure, 
                :estimated_gate_arrival, :estimated_runway_departure, 
                :estimated_runway_arrival, :actual_gate_departure,
                :actual_gate_arrival, :actual_runway_departure,
                :actual_runway_arrival, :actual_air_time, :actual_block_time,
                :actual_aircraft_type, :airline_icao_code, :origin_icao_code, 
                :destination_icao_code, :diverted_icao_code
  
  attr_accessor :origin_airport, :destination_airport, :diverted_airport, :airline
  
  def origin_airport
    @origin_airport ||= FlightCaster::Airport.find_by_icao_code(:origin_icao_code)
  end
  
  def destination_airport
    @destination_airport ||= FlightCaster::Airport.find_by_icao_code(:destination_airport)
  end
  
  def diverted_airport
    @diverted_airport ||= FlightCaster::Airport.find_by_icao_code(:diverted_airport)
  end
  
  class << self
  
    def find(airline_icao_code, flight_number, depatring_date=nil)
      departing_date ||= Date.today
      params = { 'Service' => 'FlightHistoryGetRecordsService',
            'info.specificationFlights[0].searchCodeshares' => 'true',
            'info.flightHistoryGetRecordsRequestedData.aggregatedAirports' => 'true',
            'info.specificationDateRange.departureDateTimeMin' => "#{depatring_date.strftime('%Y-%m-%d')}T00:00",
            'info.specificationDateRange.departureDateTimeMax' => "#{depatring_date.strftime('%Y-%m-%d')}T24:00",
            'info.specificationFlights[0].airline.icaoCode' => airline_icao_code.upcase,
            'info.specificationFlights[0].flightNumber' => flight_number }
      fetch_from_flightstats(params)
    end
    
    def parse(xml)
      node = xml.class == LibXML::XML::Node ? xml : xml.root.child
      return nil if node == nil
      
      FlightStats::Flight.new do |f|
        
        node.attributes.to_h.each_pair do |key, value|
          case key
          when 'FlightNumber'
            f.number = value.to_i
          when /date/i, /(estimated|scheduled).+(departure|arrival)/i
            f.instance_variable_set('@' + key.underscore, DateTime.parse(value))
          when /number/, /air_time/, /block_time/
            f.instance_variable_set('@' + key.underscore, value.to_i)
          else
            f.instance_variable_set('@' + key.underscore, value)
          end
        end
        
        node.children.each do |e|
          case e.name
          when 'FlightHistoryCodeshare' then f.codeshares << parse_code_share(e)
          when 'Airline' 
            f.airline_icao_code = e.attributes['ICAOCode']
            f.airline = FlightStats::Airline.parse(e)
          when 'Origin' then f.origin_icao_code = e.attributes['ICAOCode']
          when 'Destination' then f.destination_icao_code = e.attributes['ICAOCode']
          when 'Diverted' then f.diverted_icao_code = e.attributes['ICAOCode']
          end
        end
        
        node.children[1..-1].each do |e|
          if e.name == "AggregatedAirport"
            port = FlightStats::Airport.parse(e)
            if port.icao_code == f.destination_icao_code
              port.timezone_offset = node.attributes['ArrivalAirportTimeZoneOffset']
              f.destination_airport = port
            elsif port.icao_code == f.origin_icao_code
              port.timezone_offset = node.attributes['DepartureAirportTimeZoneOffset']
              f.origin_airport = port
            elsif port.icao_code == f.diverted_icao_code
              port.timezone_offset = node.attributes['DivertedAirportTimeZoneOffset']
              f.diverted_airport = port
            end
          end
        end
          
      end
    end
    
  end
  
  def initialize(attributes=nil)
    @codeshares = []
    if attributes
      attributes.each_pair do |key, value|
        instance_variable_set(('@' + key.to_s).to_sym.to_s,value)
      end
    end
    result = yield self if block_given?
  end  
  
  def to_h
    { :airline_icao_code => airline_icao_code,
      :number => number,
      :departure_date => departure_date,
      :arrival_date => arrival_date,
      :history_id => history_id,
      :status => status,
      :status_code => status_code,
      :creator_code => creator_code,
      :departure_gate => departure_gate,
      :departure_terminal => departure_terminal,
      :arrival_gate => arrival_gate,
      :arrival_terminal => arrival_terminal,
      :baggage_claim => baggage_claim,
      :tail_number => tail_number,
      :codeshares => codeshares,
      :published_departure_date => published_departure_date,
      :published_arrival_date => published_arrival_date,
      :scheduled_gate_departure => scheduled_gate_departure,
      :scheduled_gate_arrival => scheduled_gate_arrival,
      :scheduled_runway_departure => scheduled_runway_departure,
      :scheduled_runway_arrival => scheduled_runway_arrival,
      :scheduled_air_time => scheduled_air_time,
      :scheduled_block_time => scheduled_block_time,
      :scheduled_aircraft_type => scheduled_aircraft_type,
      :estimated_gate_departure => estimated_gate_departure,
      :estimated_gate_arrival => estimated_gate_arrival,
      :estimated_runway_departure => estimated_runway_departure, 
      :estimated_runway_arrival => estimated_runway_arrival,
      :actual_gate_departure => actual_gate_departure,
      :actual_gate_arrival => actual_gate_arrival,
      :actual_runway_departure => actual_runway_departure,
      :actual_runway_arrival => actual_runway_arrival,
      :actual_air_time => actual_air_time,
      :actual_block_time => actual_block_time,
      :actual_aircraft_type => actual_aircraft_type,
      :airline_icao_code => airline_icao_code,
      :origin_icao_code => origin_icao_code, 
      :destination_icao_code => destination_icao_code,
      :diverted_icao_code => diverted_icao_code
    }
  end
  
  
  private
  
    def self.fetch_from_flightstats(params)
      parse(FlightStats.query(params))    
    end
    
    def self.parse_code_share(xml)
      { :designator => xml.attributes['Designator'],
        :airline_icao => xml.children[0].attributes['ICAOCode'],
        :number => xml.attributes['FlightNumber'] }
    end
  
end