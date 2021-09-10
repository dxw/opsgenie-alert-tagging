require 'spec_helper'
require './lib/opsgenie_alert_tagging'
require './lib/opsgenie_alert'

RSpec.describe OpsgenieAlertTagging do
  before(:each) do
    allow(HTTParty).to receive(:get).and_return("data" => fake_opsgenie_alerts_empty_tags)
  end
  let(:date) { "2021-08-22" }
  let(:subject) { OpsgenieAlertTagging.new(date) }

  describe '#list_all_alerts' do

    it 'returns alerts from OpsGenie for a given date' do
      expect(HTTParty).to receive(:get)
        .with(
          "https://api.opsgenie.com/v2/alerts?query=createdAt%3A22-08-2021&sort=createdAt&order=desc",
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
    before do
      allow_any_instance_of(OpsgenieAlert).to receive(:bank_holidays).and_return(fake_bank_holidays)
    end

    it 'adds tag for inhours alerts'  do
      inhours_result = {:tags=>["inhours"], :id=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(inhours_result)
    end

    it 'adds tag for wakinghours weekday alerts' do
      wakinghours_weekday_result = {:tags=>["wakinghours", "OOH"], :id=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(wakinghours_weekday_result)
    end

    it 'adds tag for wakinghours weekend alerts' do
      wakinghours_weekend_result = {:tags=>["wakinghours", "OOH"], :id=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(wakinghours_weekend_result)
    end

    it 'adds tag for sleepinghours alerts' do
      sleepinghours_result = {:tags=>["sleepinghours", "OOH"], :id=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(sleepinghours_result)
    end

    it 'adds tag for bank holiday alerts' do
      wakinghours_bank_holiday_result = {:tags=>["wakinghours", "OOH"], :id=>"g4747aac-fa97-4838-8e2f-69992de30a1c-1629601435423"}
      outcome = subject.all_updated_alerts
      expect(outcome).to include(wakinghours_bank_holiday_result)
    end

    context 'when an alert has a tag present' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return("data" => fake_opsgenie_alerts_with_existing_tags)
      end

      it 'only adds unique tags to the alert' do
        result_with_unique_tags = {:tags=>["wakinghours", "OOH"], :id=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401"}
        outcome = subject.all_updated_alerts
        expect(outcome).to include(result_with_unique_tags)
      end
    end

    context 'when an alert is created at 23:00' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return("data" => [fake_alert_sleepinghours_set_time])
      end

      it 'tags the alert as sleeping hours' do
        sleepinghours_result = {:tags=>["sleepinghours", "OOH"], :id=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840"}
        outcome = subject.all_updated_alerts
        expect(outcome).to include(sleepinghours_result)
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
      fake_alert_inhours_weekday,
      fake_alert_wakinghours_weekday,
      fake_alert_sleepinghours,
      fake_alert_wakinghours_weekend,
      fake_alert_wakinghours_bank_holiday
    ]
  end

  def fake_opsgenie_alerts_with_existing_tags
    [
      fake_alert_inhours_weekday_tags_existing,
      fake_alert_wakinghours_weekday_tags_existing,
      fake_alert_sleepinghours_tags_existing,
      fake_alert_wakinghours_weekend_tags_existing,
      fake_alert_bank_holiday_existing
    ]
  end

  def fake_alert_inhours_weekday
    {
      "id"=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865",
      "tags"=>[],
      "createdAt"=>"2021-08-23T11:18:25.865Z"
    }
  end

  def fake_alert_wakinghours_weekday
    {
      "id"=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592",
      "tags"=>[],
      "createdAt"=>"2021-08-24T20:12:29.592Z"
    }
  end

  def fake_alert_wakinghours_weekend
    {
      "id"=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401",
      "tags"=>[],
      "createdAt"=>"2021-08-22T13:20:55.401Z"
    }
  end

  def fake_alert_sleepinghours
    {
      "id"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "tags"=>[],
      "createdAt"=>"2021-08-22T04:21:44.84Z"
    }
  end

  def fake_alert_wakinghours_bank_holiday
    {
      "id"=>"g4747aac-fa97-4838-8e2f-69992de30a1c-1629601435423",
      "tags"=>[],
      "createdAt"=>"2022-06-02T13:18:55.401Z"
    }
  end

  def fake_alert_inhours_weekday_tags_existing
    {
      "id"=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865",
      "tags"=>["inhours"],
      "createdAt"=>"2021-08-23T11:18:25.865Z"}
  end

  def fake_alert_wakinghours_weekday_tags_existing
    {
      "id"=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592",
      "tags"=>["wakinghours", "OOH"],
      "createdAt"=>"2021-08-24T20:12:29.592Z"
    }
  end

  def fake_alert_wakinghours_weekend_tags_existing
    {
      "id"=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401",
      "tags"=>["wakinghours", "OOH"],
      "createdAt"=>"2021-08-22T13:20:55.401Z"
    }
  end

  def fake_alert_sleepinghours_tags_existing
    {
      "id"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "tags"=>["sleepinghours", "OOH"],
      "createdAt"=>"2021-08-22T04:21:44.84Z"
    }
  end

  def fake_alert_bank_holiday_existing
    {
      "id"=>"g4747aac-fa97-4838-8e2f-69992de30a1c-1629601435423",
      "tags"=>["wakinghours", "OOH"],
      "createdAt"=>"2022-06-02T13:18:55.401Z"
    }
  end

  def fake_alert_sleepinghours_set_time
    {
      "id"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "tags"=>[],
      "createdAt"=>"2021-08-22T23:00:00.00Z"
    }
  end
end