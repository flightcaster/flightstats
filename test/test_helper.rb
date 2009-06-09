require 'rubygems'
require 'test/unit'
require 'fakeweb'

FLIGHTSTATS_GUID = 'test'

$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'flightstats'