require 'rubygems'
require 'metric_fu'
require 'spec/rake/spectask'

task :test do
  require 'lib/flightstats'
  FLIGHTSTATS_GUID = '70cbe593c1d6de05:28bcb570:1209d62fd3a:-1b12'
  FlightStats::DataFeed.new(Time.now.utc - 60*60).updates do |f, c| 
      puts f.attributes.inspect
  end
end

MetricFu::Configuration.run do |config|
    config.metrics  = [:churn, :saikuro, :flog, :flay, :reek, :roodi]
    config.flay     = { :dirs_to_flay => ['lib']  } 
    config.flog     = { :dirs_to_flog => ['lib']  }
    config.reek     = { :dirs_to_reek => ['lib']  }
    config.roodi    = { :dirs_to_roodi => ['lib'] }
    config.saikuro  = { :output_directory => 'tmp/scratch/saikuro', 
                        :input_directory => ['lib'],
                        :cyclo => "",
                        :filter_cyclo => "0",
                        :warn_cyclo => "5",
                        :error_cyclo => "7",
                        :formater => "text"} #this needs to be set to "text"
    config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
    config.rcov     = { :test_files => ['test/*_test.rb',
                                        'spec/*_spec.rb'],
                        :rcov_opts => ["--sort coverage", 
                                       "--no-html", 
                                       "--text-coverage",
                                       "--no-color",
                                       "--profile",
                                       "--spec-only",
                                       "--exclude /gems/,/Library/,spec"]}
end