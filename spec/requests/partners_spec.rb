require 'rails_helper'

RSpec.describe "Partners", type: :request do
  describe "/partners" do
    it "returns http success" do
      get "/partners"
      expect(response).to have_http_status(:success)
    end
  end

  describe "/partners/:id" do
    it "returns http success" do
      partner = given_a_partner_exists

      get "/partners/#{partner.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "/partners/:id/previous_events" do
    it "returns http success" do
      partner = given_a_partner_exists
      get "/partners/#{partner.id}/previous_events"
      expect(response).to have_http_status(:success)
    end
  end

  def given_a_partner_exists
    Partner.create!(
      name: 'Alpha doodle',
      placecal_id: 123456
    )
  end
end
