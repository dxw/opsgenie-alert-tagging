require 'spec_helper'
require './lib/opsgenie_alert_tagging'
require './lib/opsgenie_alert'

RSpec.describe OpsgenieAlertTagging do
  let(:date) { "2021-08-22" }
  let(:subject) { OpsgenieAlertTagging.new(date) }

  before do
    allow(HTTParty).to receive(:get).and_return("data" => fake_opsgenie_alerts_empty_tags)
    allow(WorkTime).to receive(:bank_holidays).and_return(fake_bank_holidays)
  end

  describe '#list_all_alerts' do

    it 'returns alerts from OpsGenie for a given date' do
      expect(HTTParty).to receive(:get)
        .with(
          "https://api.opsgenie.com/v2/alerts?limit=100&query=createdAt%3A22-08-2021&sort=createdAt&order=desc",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => anything
          }
        )
        .and_return("data" => fake_opsgenie_alerts_empty_tags)

      result = subject.list_all_alerts

      expect(result).to eq(fake_opsgenie_alerts_empty_tags)
    end
  end

  describe '#all_updated_alerts' do
    it 'adds tag for in hours alerts'  do
      in_hours_result = {:tags=>["inhours"], :id=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(in_hours_result)
    end

    it 'adds tag for out of hours alerts'  do
      out_of_hours_result = {:tags=>["OOH", "wakinghours"], :id=>"ssg5bfb-0987-2j5i-y876-5f8ad111cf45-2846378651987"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(out_of_hours_result)
    end

    it 'adds tag for waking hours alerts' do
      waking_hours_weekday_result = {:tags=>["OOH", "wakinghours"], :id=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(waking_hours_weekday_result)
    end

    it 'adds tag for weekend waking hours alerts' do
      waking_hours_weekend_result = {:tags=>["OOH", "wakinghours"], :id=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(waking_hours_weekend_result)
    end

    it 'adds tag for sleeping hours alerts' do
      sleeping_hours_result = {:tags=>["OOH", "sleepinghours"], :id=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(sleeping_hours_result)
    end

    it 'adds tag for bank holiday alerts' do
      waking_hours_bank_holiday_result = {:tags=>["OOH", "wakinghours"], :id=>"g4747aac-fa97-4838-8e2f-69992de30a1c-1629601435423"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(waking_hours_bank_holiday_result)
    end

    context 'when an alert has a tag present' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return("data" => fake_opsgenie_alerts_with_existing_tags)
      end

      it 'only adds unique tags to the alert' do
        result_with_unique_tags = {:tags=>["OOH", "wakinghours"], :id=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401"}
        outcome = subject.all_updated_alerts
        expect(outcome).to include(result_with_unique_tags)
      end
    end

    context 'when an alert is created at 23:00' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return("data" => [fake_alert_sleeping_hours_set_time])
      end

      it 'tags the alert as sleeping hours' do
        sleeping_hours_result = {:tags=>["OOH", "sleepinghours"], :id=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840"}
        outcome = subject.all_updated_alerts
        expect(outcome).to include(sleeping_hours_result)
      end
    end
  end

  describe '.tag_alerts_on_opsgenie' do
    it 'updates alert in Opsgenie ' do

      allow(subject).to receive(:all_updated_alerts).and_return([{:tags=>["inhours"], :id=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865"}])

      expect(HTTParty).to receive(:post)
        .with(
          "https://api.opsgenie.com/v2/alerts/ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865/tags",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => anything
          },
          :body => { tags: ["inhours"] }.to_json
        ).and_return({result: "this is a result"})

        subject.tag_alerts_on_opsgenie
    end
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

  def fake_opsgenie_alerts_empty_tags
    [
      fake_alert_in_hours,
      fake_alert_out_of_hours,
      fake_alert_waking_hours,
      fake_alert_weekend_waking_hours,
      fake_alert_sleeping_hours,
      fake_alert_bank_holidays
    ]
  end

  def fake_opsgenie_alerts_with_existing_tags
    [
      fake_alert_in_hours_tags_existing,
      fake_alert_out_of_hours_tags_existing,
      fake_alert_waking_hours_tags_existing,
      fake_alert_weekend_waking_hours_tags_existing,
      fake_alert_sleeping_hours_tags_existing,
      fake_alert_bank_holidays_tags_existing
    ]
  end

  def fake_alert_in_hours
    {
      "id"=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865",
      "tags"=>[],
      "createdAt"=>"2021-08-23T11:18:25.865Z"
    }
  end

  def fake_alert_out_of_hours
    {
      "id"=>"ssg5bfb-0987-2j5i-y876-5f8ad111cf45-2846378651987",
      "tags"=>[],
      "createdAt"=>"2021-08-23T20:00:25.865Z"
    }
  end

  def fake_alert_waking_hours
    {
      "id"=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592",
      "tags"=>[],
      "createdAt"=>"2021-08-24T20:12:29.592Z"
    }
  end

  def fake_alert_weekend_waking_hours
    {
      "id"=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401",
      "tags"=>[],
      "createdAt"=>"2021-08-22T13:20:55.401Z"
    }
  end

  def fake_alert_sleeping_hours
    {
      "id"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "tags"=>[],
      "createdAt"=>"2021-08-22T04:21:44.84Z"
    }
  end

  def fake_alert_bank_holidays
    {
      "id"=>"g4747aac-fa97-4838-8e2f-69992de30a1c-1629601435423",
      "tags"=>[],
      "createdAt"=>"2022-06-02T13:18:55.401Z"
    }
  end

  def fake_alert_in_hours_tags_existing
    {
      "id"=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865",
      "tags"=>["inhours"],
      "createdAt"=>"2021-08-23T11:18:25.865Z"}
  end

  def fake_alert_out_of_hours_tags_existing
    {
      "id"=>"ssg5bfb-0987-2j5i-y876-5f8ad111cf45-2846378651987",
      "tags"=>["OOH"],
      "createdAt"=>"2021-08-23T22:00:25.865Z"
    }
  end

  def fake_alert_waking_hours_tags_existing
    {
      "id"=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592",
      "tags"=>["wakinghours"],
      "createdAt"=>"2021-08-24T20:12:29.592Z"
    }
  end

  def fake_alert_weekend_waking_hours_tags_existing
    {
      "id"=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401",
      "tags"=>["OOH", "wakinghours"],
      "createdAt"=>"2021-08-22T13:20:55.401Z"
    }
  end

  def fake_alert_sleeping_hours_tags_existing
    {
      "id"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "tags"=>["sleepinghours"],
      "createdAt"=>"2021-08-22T04:21:44.84Z"
    }
  end

  def fake_alert_bank_holidays_tags_existing
    {
      "id"=>"g4747aac-fa97-4838-8e2f-69992de30a1c-1629601435423",
      "tags"=>["OOH", "wakinghours"],
      "createdAt"=>"2022-06-02T13:18:55.401Z"
    }
  end

  def fake_alert_sleeping_hours_set_time
    {
      "id"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "tags"=>[],
      "createdAt"=>"2021-08-22T23:00:00.00Z"
    }
  end
end