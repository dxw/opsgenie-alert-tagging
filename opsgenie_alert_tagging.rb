require './lib/opsgenie_alert_tagging'
require './lib/opsgenie_alert'

OpsgenieAlertTagging.new(ARGV[0]).call