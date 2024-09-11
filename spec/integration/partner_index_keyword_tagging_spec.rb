
require 'rails_helper'

RSpec.describe "Partners with keywords", type: :feature do
    before :each do
      partner = Partner.create! name: 'London Hoxton Jam makers', placecal_id: 100

      # do it this way
      keyword = Keyword.create! name: 'Alpha Keyword'
      partner.keywords << keyword

      # do it the other way (for my sanity)
      other_keyword = Keyword.create! name: 'Beta Keyword'
      other_keyword.partners << partner
    end

    it 'when set by user' do
      visit '/'
      click_link 'Partners'

      expect(page).to have_selector('article.partner .keyword', text: 'Alpha Keyword')
      expect(page).to have_selector('article.partner .keyword', text: 'Beta Keyword')
    end
end
