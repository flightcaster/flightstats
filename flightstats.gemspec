# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flightstats}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Bracy, Jon Bracy"]
  s.date = %q{2009-05-04}
  s.description = %q{A wrapper for the FlightStats API}
  s.email = %q{crew@flightcaster.com}
  s.extra_rdoc_files = ["lib/flightstats/airline.rb", "lib/flightstats/airport/delay/closed_delay.rb", "lib/flightstats/airport/delay/general_arrival_delay.rb", "lib/flightstats/airport/delay/general_delay.rb", "lib/flightstats/airport/delay/general_departure_delay.rb", "lib/flightstats/airport/delay/ground_delay.rb", "lib/flightstats/airport/delay/ground_stop_delay.rb", "lib/flightstats/airport/delay.rb", "lib/flightstats/airport.rb", "lib/flightstats/flight.rb", "lib/flightstats/metar_report.rb", "lib/flightstats/weather_report.rb", "lib/flightstats.rb", "README.rdoc"]
  s.files = ["lib/flightstats/airline.rb", "lib/flightstats/airport/delay/closed_delay.rb", "lib/flightstats/airport/delay/general_arrival_delay.rb", "lib/flightstats/airport/delay/general_delay.rb", "lib/flightstats/airport/delay/general_departure_delay.rb", "lib/flightstats/airport/delay/ground_delay.rb", "lib/flightstats/airport/delay/ground_stop_delay.rb", "lib/flightstats/airport/delay.rb", "lib/flightstats/airport.rb", "lib/flightstats/flight.rb", "lib/flightstats/metar_report.rb", "lib/flightstats/weather_report.rb", "lib/flightstats.rb", "Manifest", "Rakefile", "README.rdoc", "flightstats.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/flightcaster/flightstats}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Flightstats", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{flightstats}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{A wrapper for the FlightStats API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0", "= 1.1.3"])
    else
      s.add_dependency(%q<libxml-ruby>, [">= 0", "= 1.1.3"])
    end
  else
    s.add_dependency(%q<libxml-ruby>, [">= 0", "= 1.1.3"])
  end
end