require 'rails_helper'

RSpec.describe "Partner search", type: :feature do
  context 'filters' do
    it 'when set by user' do
      visit '/'
      click_link 'Partners'
      fill_in :name, with: 'Hox'
      click_button 'Apply'

      expect(page).to have_selector('article.partner', count: 1)
    end
  end
end
