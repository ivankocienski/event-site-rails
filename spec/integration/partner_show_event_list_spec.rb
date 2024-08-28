require 'rails_helper'

RSpec.describe "Partner show", type: :feature do
  context 'event list' do
    it 'is visible' do
      travel_to FakeTime::TODAY do
        visit '/'
        click_link 'Partners'
        click_link 'London Friend'

        expect(page).to have_selector('.partner-event-list a', count: 9)
      end
    end
  end
end
