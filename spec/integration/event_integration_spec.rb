
require 'rails_helper'

RSpec.describe "Events", type: :feature do
  before :each do
    FakeEvents.given_some_fake_events_exist
  end

  context 'index' do
    context 'with no filtering active' do
      it 'shows a list of events, grouped by day' do
        travel_to FakeEvents::NOW do
          visit "/events"
          expect(page).to have_selector('h1', text: 'Events')
          expect(page).to have_selector('.events-listing h2', count: 4)
          expect(page).to have_selector('.events-listing p', count: 26)
        end
      end
    end

    context 'with filtering' do
      it 'can show events on only one day' do
        travel_to FakeEvents::NOW do
          visit "/events"
          click_link 'Wednesday 3 June, 2020'
          expect(page).to have_selector('h1', text: 'Events on 2020-06-03')
          expect(page).to have_selector('.events-listing p', count: 7)
        end
      end
    end
  end

end
