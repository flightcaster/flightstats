class FlightStats::MetarReport

  attr_accessor :icao_code, :issue_date, :altitude, :type, :modifier,
                :wind_direction_varying, :wind_direction, :wind_gusts,
                :wind_speed, :variable_wind_direction, :visibility,
                :visibility_less_than_stated, :temperature, :dew_point,
                :barometric_pressure, :remark, :original_report,
                :sky_conditions, :weather_conditions, :weather_condition_id,
                :runway_conditions

  alias :station_code :icao_code
  alias :pressure_at_sea_level :barometric_pressure

  class << self

    def find_by_icao_code(code)
      params = {'Service' => 'MetarGetCurrentConditionsForWeatherStationService',
                'weatherStation.icaoCode' => code.upcase}
      fetch_from_flightstats(params)
    end
    
    def parse(xml)
      node = xml.class == LibXML::XML::Node ? xml : xml.root.child
      return nil if node == nil

      FlightStats::MetarReport.new do |a|
        a.icao_code = node.attributes['Station']
        a.altitude = node.attributes['Altimeter'].to_f
        a.issue_date = DateTime.parse(node.attributes['IssueDate'])
        a.type = (['AO1','AO2'].include?(node.attributes['StationType']) ? node.attributes['StationType'] : nil)
        a.modifier = node.attributes['ReportModifier']
        a.wind_direction = node.attributes['WindDirection'].to_i
        a.wind_direction_varying = (node.attributes['IsWindDirectionVariable'] == 'true')
        a.variable_wind_direction= node.attributes['VariableWindDirection'].to_i
        a.wind_speed = node.attributes['WindSpeed'].to_f
        a.wind_gusts = node.attributes['WindGusts'].to_f
        a.visibility = node.attributes['Visibility'].to_f
        a.visibility_less_than_stated = (node.attributes['IsVisibilityLessThan'] == 'ture')
        a.temperature = node.attributes['Temperature'].to_i
        a.dew_point = node.attributes['DewPoint'].to_i
        a.barometric_pressure = node.attributes['SeaLevelPressure'].to_f
        
        node.children.each do |child|
          case child.name
          when 'Remark' then a.remark = child.content.strip
          when 'OriginalReport' then a.original_report = child.content.strip
          when 'SkyCondition' then a.sky_conditions << child.content.strip
          when 'PresentWeatherCondition' then a.weather_conditions << child.content.strip
          when 'RunwayGroup' then a.runway_conditions << parse_runway_condition_xml(e)
          end
        end
        
      end
    end
    
    def parse_runway_conditions(node)
      {:number => node.attributes['RunwayNumber'],
       :approach_direction => node.attributes['ApproachDirection'],
       :max_visible => node.attributes['MaxVisible'].to_i,
       :min_visible => node.attributes['MinVisible'].to_i,
       :max_prefix => node.attributes['MaxPrefix'],
       :min_prefix => node.attributes['MinPrefix'],
       :varying_visibility => node.attributes['IsVarying'] == 'true'}
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

  def initialize(attributes=nil)
    @weather_conditions = []
    @sky_conditions = []
    @runway_conditions = []
    if attributes
      attributes.each_pair do |key, value|
        instance_variable_set(('@' + key.to_s).to_sym.to_s,value)
      end
    end
    result = yield self if block_given?
    @weather_condition_id = FlightStats::MetarReport::calculate_condition_id(@weather_conditions.join)
    if @weather_condition_id == 0
      @weather_condition_id = FlightStats::MetarReport::calculate_condition_id(@sky_conditions.join)
    end
  end
  
  def to_h
    { :icao_code => icao_code,
      :issue_date => issue_date,
      :altitude => altitude,
      :type => type,
      :modifier => modifier,
      :wind_direction_varying => wind_direction_varying,
      :wind_direction => wind_direction,
      :wind_gusts => wind_gusts,
      :wind_speed => wind_speed,
      :variable_wind_direction => variable_wind_direction,
      :visibility => visibility,
      :visibility_less_than_stated => visibility_less_than_stated,
      :temperature => temperature,
      :dew_point => dew_point,
      :barometric_pressure => barometric_pressure,
      :remark => remark,
      :original_report => original_report,
      :sky_conditions => sky_conditions,
      :weather_conditions => weather_conditions,
      :weather_condition_id => weather_condition_id,
      :runway_conditions => runway_conditions
    }
  end

  private

    def self.fetch_from_flightstats(params)
      parse(FlightStats.query(params))    
    end

end
