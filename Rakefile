require 'rubygems'
require 'metric_fu'
require 'rake/testtask'

MetricFu::Configuration.run do |config|
    config.metrics  = [:churn, :saikuro, :flog, :flay, :reek, :roodi, :rcov]
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
    config.rcov     = { :test_files => ['test/*_test.rb','test/*_test.rb'],
                        :rcov_opts => ["--sort coverage",
                                       "--no-html", 
                                       "--text-coverage",
                                       "--no-color",
                                       "--profile",
                                       "--exclude /gems/,/Library/,spec"]}
end

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_test.rb']
end