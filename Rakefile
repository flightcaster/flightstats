require 'rubygems'

require 'hoe'
Hoe.new('flightstats', '0.0.1') do |p|
  p.url = 'http://github.com/flightcaster/noaa'
  p.description = "A wrapper for the FlightStats API"
  p.email = "crew@flightcaster.com"
  p.summary = "A wrapper for the FlightStats API"
  # p.changes = p.paragraphs_of('CHANGELOG', 0..1).join("\n\n")
  # p.remote_rdoc_dir = '' # Release to root
  p.developer('James Bracy', 'james@flightcaster.com')
  p.developer('Jon Bracy', 'jon@flightcaster.com')
  p.extra_deps = [ ["libxml-ruby >= 1.1.3"] ]
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }


require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |t|
#  t.warning = true
#  t.rcov = true
  t.spec_files = Dir["#{File.dirname(__FILE__)}/test/*_spec.rb"]
end

# vim: syntax=Ruby
