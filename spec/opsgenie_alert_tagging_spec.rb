require 'spec_helper'
require './lib/opsgenie_alert_tagging'

RSpec.describe OpsgenieAlertTagging do
  before(:each) do
    allow(HTTParty).to receive(:get).and_return("data" => fake_opsgenie_alerts_empty_tags)
  end

  let(:subject) { OpsgenieAlertTagging.new("2021-9-2") }

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

      result = subject.list_all_alerts("2021-08-22")

      expect(result).to eq(fake_opsgenie_alerts_empty_tags)
    end
  end

  
  def fake_opsgenie_alerts_empty_tags
    [
      fake_alert_inhours_weekday,
      fake_alert_wakinghours_weekday,
      fake_alert_sleepinghours,
      fake_alert_wakinghours_weekend
    ]
  end

  def fake_alert_inhours_weekday
    {"seen"=>true,
      "id"=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865",
      "tinyId"=>"3255",
      "alias"=>"ccd0bcac-2235-4d9f-a043-5f8ad111cf45-1629609505865",
      "message"=>"[Updown.io] Timeout was reached",
      "status"=>"closed",
      "acknowledged"=>false,
      "isSeen"=>true,
      "tags"=>[],
      "snoozed"=>false,
      "count"=>1,
      "lastOccurredAt"=>"2021-08-23T11:18:25.865Z",
      "createdAt"=>"2021-08-23T11:18:25.865Z",
      "updatedAt"=>"2021-09-02T12:08:50.83Z",
      "source"=>"UpdownIO",
      "owner"=>"",
      "priority"=>"P3",
      "teams"=>[{"id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "responders"=>[{"type"=>"team", "id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "integration"=>{"id"=>"ae438e99-b745-452d-a8a3-14b766e0c3fd", "name"=>"Working Hours - updown.io", "type"=>"UpdownIO"},
      "report"=>{"ackTime"=>274757772, "closeTime"=>274757772, "closedBy"=>"bob@dxw.com"},
      "ownerTeamId"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}
  end

  def fake_alert_wakinghours_weekday
    {"seen"=>true,
      "id"=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592",
      "tinyId"=>"3254",
      "alias"=>"f76eb5dc-a942-4c3b-bf34-695daf171e06-1629609149592",
      "message"=>"[Updown.io] Timeout was reached",
      "status"=>"closed",
      "acknowledged"=>false,
      "isSeen"=>true,
      "tags"=>[],
      "snoozed"=>false,
      "count"=>1,
      "lastOccurredAt"=>"2021-08-24T20:12:29.592Z",
      "createdAt"=>"2021-08-24T20:12:29.592Z",
      "updatedAt"=>"2021-09-02T22:08:51.015Z",
      "source"=>"UpdownIO",
      "owner"=>"",
      "priority"=>"P3",
      "teams"=>[{"id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "responders"=>[{"type"=>"team", "id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "integration"=>{"id"=>"ae438e99-b745-452d-a8a3-14b766e0c3fd", "name"=>"Working Hours - updown.io", "type"=>"UpdownIO"},
      "report"=>{"ackTime"=>275114118, "closeTime"=>275114118, "closedBy"=>"bob@dxw.com"},
      "ownerTeamId"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}
  end

  def fake_alert_sleepinghours
    {"seen"=>true,
      "id"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "tinyId"=>"3253",
      "alias"=>"2052428d-b82a-4198-924f-7b66d568d2e1-1629606104840",
      "message"=>"[Updown.io] Timeout was reached",
      "status"=>"closed",
      "acknowledged"=>false,
      "isSeen"=>true,
      "tags"=>[],
      "snoozed"=>false,
      "count"=>1,
      "lastOccurredAt"=>"2021-08-22T04:21:44.84Z",
      "createdAt"=>"2021-08-22T04:21:44.84Z",
      "updatedAt"=>"2021-09-02T12:08:51.21Z",
      "source"=>"UpdownIO",
      "owner"=>"",
      "priority"=>"P3",
      "teams"=>[{"id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "responders"=>[{"type"=>"team", "id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "integration"=>{"id"=>"ae438e99-b745-452d-a8a3-14b766e0c3fd", "name"=>"Working Hours - updown.io", "type"=>"UpdownIO"},
      "report"=>{"ackTime"=>278158935, "closeTime"=>278158935, "closedBy"=>"bob@dxw.com"},
      "ownerTeamId"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}
  end

  def fake_alert_wakinghours_weekend
    {"seen"=>true,
      "id"=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401",
      "tinyId"=>"3252",
      "alias"=>"f4747aac-fa97-4838-8e2f-69992de30a1c-1629601435401",
      "message"=>"[Updown.io] Timeout was reached",
      "status"=>"closed",
      "acknowledged"=>false,
      "isSeen"=>true,
      "tags"=>[],
      "snoozed"=>false,
      "count"=>1,
      "lastOccurredAt"=>"2021-08-22T13:03:55.401Z",
      "createdAt"=>"2021-08-22T13:20:55.401Z",
      "updatedAt"=>"2021-09-02T14:21:51.439Z",
      "source"=>"UpdownIO",
      "owner"=>"",
      "priority"=>"P3",
      "teams"=>[{"id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "responders"=>[{"type"=>"team", "id"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}],
      "integration"=>{"id"=>"ae438e99-b745-452d-a8a3-14b766e0c3fd", "name"=>"Working Hours - updown.io", "type"=>"UpdownIO"},
      "report"=>{"ackTime"=>282828423, "closeTime"=>282828423, "closedBy"=>"bob@dxw.com"},
      "ownerTeamId"=>"72c99d92-c7c8-4fd9-b8db-9cc293cd19e7"}
  end
end
