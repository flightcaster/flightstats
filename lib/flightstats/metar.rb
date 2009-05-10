class FlightStats::METAR
  
  attr_accessor :attributes
  
  QUERY_OPTIONS = {
    :icao_code => 'weatherStation.icaoCode'
  }
  
  QUERY_PARAMS = {
    'Service' => 'MetarGetCurrentConditionsForWeatherStationService'
  }
  
  class << self
    
    # Gets the METAR given the ICAO code
    def get(icao_code)
      params = { QUERY_OPTIONS[:icao_code] => icao_code }
      params.merge!(QUERY_PARAMS)
      FlightStats::METAR.new(FlightStats.query(params))
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
    @attributes['icao_code'] = @attributes['station']
    @attributes['altimeter'] = @attributes['altimeter'].to_f
    @attributes['issued_at'] = DateTime.parse(@attributes.delete('issue_date'))
    @attributes['modifier'] = @attributes.delete('report_modifier')
    @attributes['wind_direction'] = @attributes['wind_direction'].to_i
    @attributes['wind_speed'] = @attributes['wind_speed'].to_i
    @attributes['wind_gusts'] = @attributes['wind_gusts'].to_i
    @attributes['wind_direction_varying'] = (@attributes.delete('is_wind_direction_variable') == "true")
    @attributes['variable_wind_direction'] = @attributes['variable_wind_direction'].to_i
    @attributes['visibility'] = @attributes['visibility'].to_f
    @attributes['visibility_less_than_stated'] = (@attributes['is_visibility_less_than'] == "true")
    @attributes['temperature'] = @attributes['temperature'].to_f
    @attributes['dew_point'] = @attributes['dew_point'].to_i
    @attributes['barometric_pressure'] = @attributes.delete('sea_level_pressure').to_f
    
    @attributes['sky_conditions'] = []
    @attributes['present_weather_conditions'] = []
    @attributes['runway_conditions'] = []
    node.children.each do |child|
      case child.name
      when 'Remark' then @attributes['remark'] = child.content.strip
      when 'OriginalReport' then @attributes['original_report'] = child.content.strip
      when 'SkyCondition' then @attributes['sky_conditions'] << child.content.strip
      when 'PresentWeatherCondition' then @attributes['weather_conditions'] << child.content.strip
      when 'RunwayGroup' then @attributes['runway_conditions'] << parse_runway_conditions(child)
      end
    end
  end
  
  def parse_runway_conditions(node)
    {'number' => node.attributes['RunwayNumber'],
     'approach_direction' => node.attributes['ApproachDirection'],
     'max_visible' => node.attributes['MaxVisible'].to_i,
     'min_visible' => node.attributes['MinVisible'].to_i,
     'max_prefix' => node.attributes['MaxPrefix'],
     'min_prefix' => node.attributes['MinPrefix'],
     'varying_visibility' => node.attributes['IsVarying'] == 'true'}
  end
  
  def calculate_condition_id(conditions)
    case conditions
    when /hurricane/i; 22
    when /(tornado|funnel\scloud)/i; 21
    when /(volcanic\sash|volcanic)/i; 20
    when /(ice|freezing|hail)/i; 19
    when /thunderstorm/i; 18
    when /(snow|flurr)/i; 17
    when /(sandstorm|duststorm)/i; 16
    when /(shallow|partial|patches)\s(fog|mistj)/i; 13
    when /(fog|mist)/i; 15
    when /smoke/i; 14
    when /light\sblowing/i; 11
    when /blowing/i; 12
    when /chance\sof\s(rain|percipatation)\s[56789][0123456789]\sprecent/i; 9
    when /(chance\sof\s(rain|percipatation)|shower|drizzle)/i; 8
    when /chance\sof\s(rain|percipatation)\s[01234][0123456789]\sprecent/i; 7
    when /(rain|heavy\sdrizzle|heavy\sshowers)/; 10
    when /(few\sclouds|scattered\slayer|broken\slayer)/i; 5
    when /(clouds|cloudy|overcast\slayer|sky\scover\sis)/i; 6
    when /smog/i; 4
    when /(dry|fair|mostly\sclear|partly\sclear)/i; 3
    when /clear/; 2
    when /partly\ssunny/i; 1
    when /sunny/; 0
    else; 0
    end
  end

end