require 'spec_helper'
require './lib/opsgenie_alert'

RSpec.describe OpsgenieAlert do
  let(:subject) { OpsgenieAlert.new(fake_alert) }
  let(:date_time) { "2021-03-04T10:00:00.000Z" }

  before do
    allow(WorkTime).to receive(:bank_holidays).and_return(fake_bank_holidays)
  end

  describe '#tags' do
    it 'returns the alert tags' do
      outcome = subject.tags
      expect(outcome).to eq(["inhours"])
    end
  end

  describe '#id' do
    it 'returns the alert id' do
      outcome = subject.id
      expect(outcome).to eq("ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865")
    end
  end

  describe '#created_at' do
    it 'returns the date in BST when the alert was created in the summer' do
      summer_date_time = "2021-08-22T05:18:25.865Z"
      alert = OpsgenieAlert.new("createdAt"=>summer_date_time)
      result = alert.created_at
      time_format = "%Y %b %d %H:%M:%S"
      expect(result.strftime(time_format)).to eq(Time.new(2021,8,22,6,18,25, "+01:00").strftime(time_format))
    end

    it 'returns the date in UTC for when the alert was created in the winter' do
      winter_date_time = "2021-11-30T21:18:25.865Z"
      alert = OpsgenieAlert.new("createdAt"=>winter_date_time)
      result = alert.created_at
      time_format = "%Y %b %d %H:%M:%S"
      expect(result.strftime(time_format)).to eq(Time.new(2021,11,30,21,18,25, "+00:00").strftime(time_format) )
    end
  end

  describe '#created_at_date' do
    it 'returns the date only' do
      alert = OpsgenieAlert.new("createdAt"=>date_time)
      result = alert.created_at_date
      expect(result).to eq("2021-03-04")
    end
  end

  describe '#saturday?' do
    it 'returns a true when an alert was created on a saturday' do
      saturday_date_time = "2022-09-03T10:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>saturday_date_time)
      result = alert.saturday?

      expect(result).to eq(true)
    end

    it 'returns a false when an alert was created on a day that is not saturday' do
      not_saturday_date_time = "2022-09-14T10:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>not_saturday_date_time)
      result = alert.saturday?

      expect(result).to eq(false)
    end
  end

  describe '#sunday?' do
    it 'returns a true when an alert was created on a sunday' do
      sunday_date_time = "2022-10-16T10:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>sunday_date_time)
      result = alert.sunday?

      expect(result).to eq(true)
    end

    it 'returns a false when an alert was created on a day that is not sunday' do
      not_sunday_date_time = "2022-10-13T10:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>not_sunday_date_time)
      result = alert.sunday?

      expect(result).to eq(false)
    end
  end

  describe '#in_hours?' do
    it 'returns a true when an alert was created in hours' do
      in_hours_date_time = "2022-11-11T10:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>in_hours_date_time)
      result = alert.in_hours?

      expect(result).to eq(true)
    end

    it 'returns a false when an alert was created at a time outside of in hours' do
      not_in_hours_date_time = "2022-11-11T09:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>not_in_hours_date_time)
      result = alert.in_hours?

      expect(result).to eq(false)
    end
  end

  describe '#out_of_hours?' do
    it 'returns a true when an alert was created out of hours' do
      out_of_hours_date_time = "2022-11-11T22:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>out_of_hours_date_time)
      result = alert.out_of_hours?

      expect(result).to eq(true)
    end
  end

  describe '#on_weekend?' do
    it 'returns true if alert is created on a weekend' do
      on_weekend_date_time = "2022-01-16T10:00:00.865Z"
      alert = OpsgenieAlert.new("createdAt"=>on_weekend_date_time)
      result = alert.on_weekend?

      expect(result).to eq(true)
    end
  end

  describe '#during_out_of_hours_waking_hours?' do
    it 'returns a true when an alert was created during out of of hours waking hours' do
      out_of_hours_waking_hours_date_time = "2022-12-09T09:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>out_of_hours_waking_hours_date_time)
      result = alert.during_out_of_hours_waking_hours?

      expect(result).to eq(true)
    end

    it 'returns a false when an alert was created at a time outside of out of of hours waking hours' do
      not_out_of_hours_waking_hours_date_time = "2022-12-09T05:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>not_out_of_hours_waking_hours_date_time)
      result = alert.during_out_of_hours_waking_hours?

      expect(result).to eq(false)
    end

    it 'returns a false when an alert was created in hours during waking hours' do
      in_hours_waking_hours_date_time = "2022-12-09T11:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>in_hours_waking_hours_date_time)
      result = alert.during_out_of_hours_waking_hours?

      expect(result).to eq(false)
    end

    it 'returns a true when an alert was created anytime during waking hours on a weekend' do
      weekend_waking_hours_date_time = "2022-12-11T11:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>weekend_waking_hours_date_time)
      result = alert.during_out_of_hours_waking_hours?

      expect(result).to eq(true)
    end
  end

  describe '#during_sleeping_hours?' do
    it 'returns a true when an alert was created within a sleepinghour range' do
      sleeping_date_time = "2022-01-15T05:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>sleeping_date_time)
      result = alert.during_sleeping_hours?

      expect(result).to eq(true)
    end

    it 'returns a true when an alert was created at 23:00 hours' do
      specific_sleeping_date_time = "2022-01-17T23:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>specific_sleeping_date_time)
      result = alert.during_sleeping_hours?

      expect(result).to eq(true)
    end

    it 'returns a false when an alert was created at a time outside of a sleeping hour range' do
      not_sleeping_date_time = "2022-01-11T09:00:00.000Z"
      alert = OpsgenieAlert.new("createdAt"=>not_sleeping_date_time)
      result = alert.during_sleeping_hours?

      expect(result).to eq(false)
    end
  end

  describe '#bank_holiday?' do
    it 'returns true for an alert that is on a bank holiday' do
      bank_holiday_date_time = "2022-01-03T10:00:00.865Z"
      alert = OpsgenieAlert.new("createdAt"=>bank_holiday_date_time)
      result = alert.bank_holiday?

      expect(result).to eq(true)
    end

    it 'returns false for an alert that is not on a bank holiday' do
      not_bank_holiday_date_time = "2022-09-03T10:00:00.865Z"
      alert = OpsgenieAlert.new("createdAt"=>not_bank_holiday_date_time)
      result = alert.bank_holiday?

      expect(result).to eq(false)
    end
  end

  def fake_alert
    {
      "id"=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865",
      "tags"=>["inhours"],
      "createdAt"=>"2021-08-23T11:18:25.865Z"
    }
  end

  def fake_bank_holidays
    [
      "2022-01-03",
      "2022-04-15",
      "2022-04-18",
      "2022-05-02",
      "2022-06-02",
      "2022-06-03",
      "2022-08-29",
      "2022-12-26",
      "2022-12-27"
    ]
  end

  def fake_bank_holiday_api_response
    {"england-and-wales" =>
      {"division" => "england-and-wales",
        "events" =>
           [{"title" => "New Year’s Day","date" => "2022-01-03","notes" => "Substitute day","bunting" => true},
            {"title" => "Good Friday","date" => "2022-04-15","notes" => "","bunting" => false},
            {"title" => "Easter Monday","date" => "2022-04-18","notes" => "","bunting" => true},
            {"title" => "Early May bank holiday","date" => "2022-05-02","notes" => "","bunting" => true},
            {"title" => "Spring bank holiday","date" => "2022-06-02","notes" => "","bunting" => true},
            {"title" => "Platinum Jubilee bank holiday","date" => "2022-06-03","notes" => "","bunting" => true},
            {"title" => "Summer bank holiday","date" => "2022-08-29","notes" => "","bunting" => true},
            {"title" => "Boxing Day","date" => "2022-12-26","notes" => "","bunting" => true},
            {"title" => "Christmas Day","date" => "2022-12-27","notes" => "Substitute day","bunting" => true}]
      }
    }
  end
end