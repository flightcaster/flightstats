Gem::Specification.new do |s|
  s.name = 'flightstats'
  s.version = '0.0.2'
  s.summary = 'FlightStats wrapper'
  s.date = '2009-09-24'
  s.authors = ['FlightCaster', 'Jon Bracy']
  s.email = 'dev@flightcaster.com'
  s.homepage = 'http://flightcaster.com/'
  s.add_dependency('libxml-ruby', '>= 1.1.3')
  s.add_dependency('tzinfo', '>= 0.3.14')
  s.files = ['Rakefile', 'README.rdoc'] + Dir['lib/**/*.rb'] + Dir['test/**/*.rb'] + Dir['test/**/*.gz'] + Dir['test/**/*.xml']
end
