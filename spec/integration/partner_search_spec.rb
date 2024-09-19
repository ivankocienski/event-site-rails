require 'rails_helper'

RSpec.describe "Partner search", type: :feature do
  context 'filters' do
    before :each do
      Partner.create! name: 'London Hoxton Jam makers', placecal_id: 100

      # also will match this
      Partner.create! name: 'The Otter and Ox', placecal_id: 101

      # not returned
      Partner.create! name: 'Another Partner', placecal_id: 102
    end

    it 'when set by user' do
      visit '/'
      click_link 'Partners'
      fill_in :name, with: 'Hox'
      click_button 'Apply'

      expect(page).to have_selector('article.partner', count: 2)
    end
  end
end
