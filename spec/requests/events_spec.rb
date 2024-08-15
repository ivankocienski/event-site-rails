require 'rails_helper'

RSpec.describe "Events", type: :request do
  before :all do
    Event.load_from_fixture(Rails.root.join('db/fixtures/events.json'))
  end

  describe "GET /events" do
    it "returns http success" do
      get "/events"
      expect(response).to have_http_status(:success)
    end
  end

  describe "/event/:id" do
    it "returns http success" do
      get "/events/361005"
      expect(response).to have_http_status(:success)
    end
  end

end
