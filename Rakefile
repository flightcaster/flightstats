require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('flightstats', '0.0.1') do |c|
  c.description     = File.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
  c.summary         = "A wrapper for the FlightStats API"
  c.url             = 'http://github.com/flightcaster/flightstats'
  c.author          = ["James Bracy", "Jon Bracy"]
  c.email           = "crew@flightcaster.com"
  c.ignore_pattern  = ['tmp/*']
  
  c.runtime_dependencies = ["libxml-ruby >= 1.1.3"]
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

