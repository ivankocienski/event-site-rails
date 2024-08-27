
require 'rails_helper'

RSpec.describe "Events", type: :feature do
  TODAY = Time.new(2024, 6, 1)

  context 'index' do
    context 'with no filtering active' do
      it 'shows a list of events, grouped by day' do
        travel_to TODAY do
          visit "/events"
          expect(page).to have_selector('h1', text: 'Events')
          expect(page).to have_selector('.events-listing h2', count: 7)
          expect(page).to have_selector('.events-listing p', count: 30)
        end
      end
    end

    context 'with filtering' do
      it 'can show events on only one day' do
        travel_to TODAY do
          visit "/events"
          click_link 'Monday 3 June, 2024'
          expect(page).to have_selector('h1', text: 'Events on Monday 3 June, 2024')
          expect(page).to have_selector('.events-listing p', count: 1)
        end
      end
    end
  end

end
