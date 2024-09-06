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
      get "/partners/192"
      expect(response).to have_http_status(:success)
    end
  end

  describe "/partners/:id/previous_events" do
    it "returns http success" do
      get "/partners/192"
      expect(response).to have_http_status(:success)
    end
  end
end
