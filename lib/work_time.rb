class WorkTime
  def self.bank_holidays
    @@bank_holidays ||= begin
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

  def self.time_with_zone(string:)
    Time.zone = 'Europe/London'
    Time.zone.parse(string)
  end

  def self.time_range_inhours
    10..18
  end

  def self.time_range_wakinghours_weekday
    [18..23, 8..10].flat_map(&:to_a)
  end

  def self.time_range_sleepinghours
    [00..8, [23]].flat_map(&:to_a)
  end

  def self.time_range_wakinghours_weekend
    8..23
  end
end

