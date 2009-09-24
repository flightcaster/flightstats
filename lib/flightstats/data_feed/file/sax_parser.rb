class FlightStats::DataFeed::File::SaxParser

  include LibXML::XML::SaxParser::Callbacks

  def initialize(&on_update_block)
    @stack = []
    @on_update_block = on_update_block
  end
  
  def to_time(string)
    return nil if string.nil?
    Time.utc(string[0..3],string[5..6],string[8..9],
             string[11..12],string[14..15],string[17..18],string[20..22])
  end
    
  def on_start_element_ns(name, attributes, prefix, uri, namespaces)
    @stack.push(name)
    attributes = attributes.delete_if{ |k,v| v.strip.empty? }

    case name
    when 'FlightHistoryEvent'
      @update = FlightStats::DataFeed::File::FlightUpdate.new
      @update.source = attributes['DataSource']
      @update.event = attributes['Event']
      @update.data_updated = attributes['DataUpdated']
      tz = TZInfo::Timezone.get('America/Los_Angeles')
      @update.timestamp = tz.local_to_utc(to_time(attributes['DateTimeRecorded']))
    when 'FlightHistory'
      @flight = FlightStats::Flight.new
      @flight.id = attributes['FlightHistoryId']
      @flight.number = attributes['FlightNumber']
      @flight.tail_number = attributes['TailNumber']
      @flight.status = attributes['Status']
      @flight.status_code = attributes['StatusCode']
      @flight.creator_code = attributes['CreatorCode']
      @flight.published_local_departure_time = to_time(attributes['PublishedDepartureDate'])
      @flight.published_local_arrival_time = to_time(attributes['PublishedArrivalDate'])
      @flight.local_arrival_time = to_time(attributes['PublishedArrivalDate'])
      @flight.scheduled_local_gate_departure_time = to_time(attributes['ScheduledGateDepartureDate'])
      @flight.estimated_local_gate_departure_time = to_time(attributes['EstimatedGateDepartureDate'])
      @flight.actual_local_gate_departure_time = to_time(attributes['ActualGateDepartureDate'])
      @flight.scheduled_local_gate_arrival_time = to_time(attributes['ScheduledGateArrivalDate'])
      @flight.estimated_local_gate_arrival_time = to_time(attributes['EstimatedGateArrivalDate'])
      @flight.actual_local_gate_arrival_time = to_time(attributes['ActualGateArrivalDate'])
      @flight.scheduled_local_runway_departure_time = to_time(attributes['ScheduledRunwayDepartureDate'])
      @flight.estimated_local_runway_departure_time = to_time(attributes['EstimatedRunwayDepartureDate'])
      @flight.actual_local_runway_departure_time = to_time(attributes['ActualRunwayDepartureDate'])
      @flight.scheduled_local_runway_arrival_time = to_time(attributes['ScheduledRunwayArrivalDate'])
      @flight.estimated_local_runway_arrival_time = to_time(attributes['EstimatedRunwayArrivalDate'])
      @flight.actual_local_runway__arrival_time = to_time(attributes['ActualRunwayArrivalDate'])
      @flight.scheduled_air_time = attributes['ScheduledAirTime'].to_i if attributes['ScheduledAirTime']
      @flight.actual_air_time = attributes['ActualAirTime'].to_i if attributes['ActualAirTime']
      @flight.scheduled_block_time = attributes['ScheduledBlockTime'].to_i if attributes['ScheduledBlockTime']
      @flight.actual_block_time = attributes['ActualBlockTime'].to_i if attributes['ActualBlockTime']
      @flight.departure_airport_timezone_offset = attributes['DepartureAirportTimeZoneOffset'].to_f if attributes['DepartureAirportTimeZoneOffset']
      @flight.arrival_airport_timezone_offset = attributes['ArrivalAirportTimeZoneOffset'].to_f if attributes['ArrivalAirportTimeZoneOffset']
      @flight.diverted_airport_timezone_offset = attributes['DivertedAirportTimeZoneOffset'].to_f if attributes['DivertedAirportTimeZoneOffset']
      @flight.local_departure_time = to_time(attributes['DepartureDate'])
      @flight.local_arrival_time = to_time(attributes['ArrivalDate'])
      @flight.scheduled_aircraft_type = attributes['ScheduledAircraftType']
      @flight.actual_aircraft_type = attributes['ActualAircraftType']
      @flight.departure_gate = attributes['DepartureGate']
      @flight.departure_terminal = attributes['DepartureTerminal']
      @flight.arrival_gate = attributes['ArrivalGate']
      @flight.arrival_terminal = attributes['ArrivalTerminal']
      @flight.baggage_claim = attributes['BaggageClaim']
    when 'FlightHistoryCodeshare', 'CodeshareEntry'
      @codeshare = FlightStats::Flight::Codeshare.new
      @codeshare.id = attributes['FlightHistoryCodeshareId']
      @codeshare.number = attributes['FlightNumber']
      @codeshare.tail_number = attributes['TailNumber']
      @codeshare.published_local_departure_time = to_time(attributes['PublishedDepartureDate'])
      @codeshare.published_local_arrival_time = to_time(attributes['PublishedArrivalDate'])
      @codeshare.designator = attributes['Designator']
    when 'Airline'
      @airline = FlightStats::Airline.new
      @airline.code = attributes['AirlineCode']
      @airline.name = attributes['Name']
      @airline.iata_code = attributes['IATACode']
      @airline.icao_code = attributes['ICAOCode']
      @airline.faa_code = attributes['FAACode']
    when 'Origin'
      @origin = FlightStats::Airport.new
      @origin.code = attributes['AirportCode']
      @origin.iata_code = attributes['IATACode']
      @origin.icao_code = attributes['ICAOCode']
      @origin.faa_code = attributes['FAACode']
      @origin.name = attributes['Name']
    when 'Destination'
      @destination = FlightStats::Airport.new
      @destination.code = attributes['AirportCode']
      @destination.iata_code = attributes['IATACode']
      @destination.icao_code = attributes['ICAOCode']
      @destination.faa_code = attributes['FAACode']
      @destination.name = attributes['Name']
    when 'Diverted'
      @diverted = FlightStats::Airport.new
      @diverted.code = attributes['AirportCode']
      @diverted.iata_code = attributes['IATACode']
      @diverted.icao_code = attributes['ICAOCode']
      @diverted.faa_code = attributes['FAACode']
      @diverted.name = attributes['Name']
    end
  end
  
  def on_end_element_ns (name, prefix, uri)
    raise 'Unclosed entity' if @stack.pop != name
    
    case name
    when 'FlightHistoryEvent'
      @on_update_block.call(@update)
      @update = nil
    when 'FlightHistory'
      @update.flight = @flight if @stack.last == 'FlightHistoryEvent'
      @flight = nil
    when 'FlightHistoryCodeshare', 'CodeshareEntry'
      @flight.codeshares << @codeshare if @stack.last == 'FlightHistory'
      @codeshare = nil
    when 'Airline'
      case @stack.last
      when 'FlightHistory'
        @flight.airline = @airline
      when 'FlightHistoryCodeshare', 'CodeshareEntry'
        @codeshare.airline = @airline
      end
      @airline = nil
    when 'Origin'
      @flight.origin = @origin if @stack.last == 'FlightHistory'
      @origin = nil
    when 'Destination'
      @flight.destination = @destination if @stack.last == 'FlightHistory'
      @destination = nil
    when 'Diverted'
      @flight.diverted = @diverted if @stack.last == 'FlightHistory'
      @diverted = nil
    end
  end
end