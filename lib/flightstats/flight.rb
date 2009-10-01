class FlightStats::Flight
  
  def initialize
    @codeshares = []
  end
  
  attr_accessor :id,
                :airline,
                :number,
                :tail_number,
                :codeshares,

                :origin,
                :destination,
                :diverted,

                :status,
                :status_code,
                :creator_code,

                :scheduled_aircraft_type,
                :actual_aircraft_type,
                :scheduled_air_time,
                :actual_air_time,
                :scheduled_block_time,
                :actual_block_time,

                :departure_gate,
                :departure_terminal,

                :local_departure_time,
                :published_local_departure_time,
                :scheduled_local_gate_departure_time,
                :estimated_local_gate_departure_time,
                :actual_local_gate_departure_time,
                :scheduled_local_runway_departure_time,
                :estimated_local_runway_departure_time,
                :actual_local_runway_departure_time,

                :arrival_gate,
                :arrival_terminal,
                :baggage_claim,
                                
                :local_arrival_time,
                :published_local_arrival_time,
                :scheduled_local_gate_arrival_time,
                :estimated_local_gate_arrival_time,
                :actual_local_gate_arrival_time,
                :scheduled_local_runway_arrival_time,
                :estimated_local_runway_arrival_time,
                :actual_local_runway_arrival_time,


                :departure_airport_timezone_offset,
                :arrival_airport_timezone_offset,
                :diverted_airport_timezone_offset

end