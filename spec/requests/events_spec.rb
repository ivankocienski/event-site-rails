require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:partner) { Partner.create! name: 'Alpha', placecal_id: 100 }

  before :each do
    Event.transaction do
      10.times do |n|
        event = Event.create! name: 'Beta', partner: partner 
        event.event_instances.create! placecal_id: 200 + n, starts_at: Time.new(2000, 6, 1 + n)
      end
    end
  end

  describe "GET /events" do
    it "returns http success" do
      get "/events"
      expect(response).to have_http_status(:success)
      expect(response).to render_template('events/index')
    end

    it "can show day view" do
      get "/events?day=2020-10-15"
      expect(response).to have_http_status(:success)
      expect(response).to render_template('events/events_by_day')
    end
  end

  describe "/event/:id" do
    it "returns http success" do
      fake_event_id = Event.all.first.id
      get "/events/#{fake_event_id}"

      expect(response).to have_http_status(:success)
    end

    it "rejects bad IDs" do
      get "/events/123456"

      expect(response).to have_http_status(404)
      expect(response).to render_template('home/not_found')
    end
  end

end
