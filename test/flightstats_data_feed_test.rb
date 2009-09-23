require File.dirname(__FILE__) + '/test_helper'

class DelayFeedTest < Test::Unit::TestCase
  
  def test_should_set_last_accessed_time
    df = FlightStats::DataFeed.new(Time.utc(2009,9,9,9,9))
    assert_equal(Time.utc(2009,9,9,9,9), df.last_accessed_at)
  end
  
  def test_should_find_two_files
    FakeWeb.register_uri(:get, "https://www.pathfinder-xml.com/development/feed?login.guid=test&useUTC=true&lastAccessed=#{Time.now.utc.strftime("%Y-%m-%dT%H:%M")}",
                         :body => File.read("#{File.dirname(__FILE__)}/responses/feed_file_list.xml"))
                         
    files = FlightStats::DataFeed.new.files
    assert_equal 2, files.size
    
    assert_equal(265293, files[0].size)
    assert_equal(Time.utc(2009,6,8,21,37), files[0].timestamp)
    assert_equal('4551477', files[0].id)
    assert_equal(1760, files[0].message_count)
  end

end