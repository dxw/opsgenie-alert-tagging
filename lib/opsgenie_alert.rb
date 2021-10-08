require 'httparty'
require 'active_support/all'
require 'active_support/time'
require 'work_time'

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
    time = WorkTime.time_with_zone(string: alert["createdAt"])
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

  def in_hours?
    return false if on_weekend?
    return false if bank_holiday?

    WorkTime.time_range_in_hours.include?(created_at.hour)
  end

  def out_of_hours?
    !in_hours?
  end

  def on_weekend?
    saturday? || sunday?
  end

  def wakinghours_weekday?
    WorkTime.time_range_wakinghours_weekday.include?(created_at.hour)
  end

  def wakinghours_weekend?
    WorkTime.time_range_wakinghours_weekend.include?(created_at.hour)
  end

  def sleepinghours?
    WorkTime.time_range_sleepinghours.include?(created_at.hour)
  end

  def bank_holiday?
    WorkTime.bank_holidays.include?(created_at_date)
  end
end