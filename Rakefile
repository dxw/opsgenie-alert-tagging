$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")

require 'opsgenie_alert_tagging'
require 'opsgenie_alert'
require 'active_support/time'

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: %i[spec]

namespace :opsgenie_alert_tagging do
  task :add_tags, [:date] do |t, args|
    if args[:date].nil? 
      OpsgenieAlertTagging.new(Date.yesterday.strftime("%Y-%m-%d")).call
    else 
      OpsgenieAlertTagging.new(args[:date]).call
    end
  end
end
