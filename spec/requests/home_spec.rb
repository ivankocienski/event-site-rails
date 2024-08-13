require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /root" do
    it "returns http success" do
      get "/home/root"
      expect(response).to have_http_status(:success)
    end
  end

end
