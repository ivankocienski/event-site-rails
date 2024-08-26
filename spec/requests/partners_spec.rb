require 'rails_helper'

RSpec.describe "Partners", type: :request do
  before :all do
    Partner.load_from_fixture(Rails.root.join('db/fixtures/partners.json'))
  end

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

end
