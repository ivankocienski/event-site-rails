require 'rails_helper'

RSpec.describe "Partner search", type: :feature do

  context 'filters' do
    before :each do
      Partner.load_from_fixture Rails.root.join('db/fixtures/partners.json')
    end

    it 'when set by user' do
      visit '/'
      click_link 'Partners'
      fill_in :name, with: 'Hox'
      click_button 'Apply'

      expect(page).to have_selector('article.partner', count: 1)
    end
  end
end
