require 'httparty'
require 'active_support/all'
require 'active_support/time'

class OpsgenieAlert

  attr_reader :alert

  def initialize(alert)
    @alert = alert
  end

  def tags
    alert["tags"]
  end

  def id
    alert["id"]
  end

  def created_at
    time = time_with_zone(string: alert["createdAt"])
  end

  def created_at_date
    alert["createdAt"].to_s.split("T")[0]
  end

  def saturday?
    created_at.saturday?
  end

  def sunday?
    created_at.sunday?
  end

  def inhours?
    time_range_inhours.include?(created_at.hour)
  end

  def wakinghours_weekday?
    time_range_wakinghours_weekday.include?(created_at.hour)
  end

  def wakinghours_weekend?
    time_range_wakinghours_weekend.include?(created_at.hour)
  end

  def sleepinghours?
    time_range_sleepinghours.include?(created_at.hour)
  end

  def bank_holiday?
    bank_holidays.include?(created_at_date)
  end

  private

  def bank_holidays
    @bank_holidays ||= begin
      results = HTTParty.get("https://www.gov.uk/bank-holidays.json",
        :headers => {
        "Content-Type" => "application/json"
      })

      events = results["england-and-wales"]["events"]
      events.map do |event|
        event["date"]
      end
    end
  end

  def time_with_zone(string:)
    Time.zone = 'Europe/London'
    Time.zone.parse(string)
  end

  def time_range_inhours
    10..18
  end

  def time_range_wakinghours_weekday
    [18..23, 8..10].flat_map(&:to_a)
  end

  def time_range_sleepinghours
    [00..8, [23]].flat_map(&:to_a)
  end

  def time_range_wakinghours_weekend
    8..23
  end
end