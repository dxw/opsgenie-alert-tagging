require 'httparty'
require 'dotenv/load'
require 'pry'

class OpsgenieAlertTagging

  attr_reader :date

  def initialize(date)
    @date = date
  end

  def call
    tag_alerts_on_opsgenie
  end

  def list_all_alerts
    parse_date = Date.parse(date)
    format_date = parse_date.strftime("%d-%m-%Y")

    results = HTTParty.get("https://api.opsgenie.com/v2/alerts?limit=100&query=createdAt%3A#{format_date}&sort=createdAt&order=desc", :headers => {
      "Content-Type" => "application/json",
      "Authorization" => "GenieKey #{ENV['OPSGENIE_API_KEY']}"
    })

    puts "There are no alerts for #{format_date}" if results["data"].empty?

    results["data"]
  end

  def all_updated_alerts
    all_alerts_for_specific_date = list_all_alerts

    all_alerts_for_specific_date.map do |raw_alert|
      alert = OpsgenieAlert.new(raw_alert)
      result = {}
      result[:tags] = alert.tags
      result[:id] = alert.id

      if alert.bank_holiday?
        result[:tags] << "wakinghours"
        result[:tags] << "OOH"

      elsif alert.in_hours?
        result[:tags] << "inhours"

      elsif alert.during_out_of_hours_waking_hours?
        result[:tags] << "wakinghours"
        result[:tags] << "OOH"

      elsif alert.during_sleeping_hours?
        result[:tags] << "sleepinghours"
        result[:tags] << "OOH"
      end

      result[:tags].uniq!
      result
    end
  end

  def tag_alerts_on_opsgenie
    all_updated_alerts.each do |alert|
      response = HTTParty.post("https://api.opsgenie.com/v2/alerts/#{alert[:id]}/tags",
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "GenieKey #{ENV['OPSGENIE_API_KEY']}"
        },
        :body => { tags: alert[:tags] }.to_json
      )
      puts "Updating OpsGenie alert #{alert[:id]} and the response was '#{response["result"]}'."
    end
  end

end