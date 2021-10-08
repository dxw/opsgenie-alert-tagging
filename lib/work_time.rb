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

  def self.time_range_in_hours
    10..18
  end

  def self.time_range_waking_hours
    8..23
  end

  def self.time_range_sleepinghours
    [00..8, [23]].flat_map(&:to_a)
  end
end

