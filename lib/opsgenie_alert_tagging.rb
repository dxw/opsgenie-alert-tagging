require 'httparty'
require 'dotenv/load'
require 'pry'

class OpsgenieAlertTagging

  attr_reader :date

  def initialize(date)
    @date = date
  end

  def list_all_alerts(date)
    parse_date = Date.parse(date)
    format_date = parse_date.strftime("%d-%m-%Y")

    results = HTTParty.get("https://api.opsgenie.com/v2/alerts?query=createdAt%3A#{format_date}&sort=createdAt&order=desc", :headers => {
      "Content-Type" => "application/json",
      "Authorization" => "GenieKey #{ENV['OPSGENIE_API_KEY']}"
    })

    results["data"]
  end
end