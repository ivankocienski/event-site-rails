
require 'rails_helper'

RSpec.describe "Events", type: :feature do

  context 'index' do
    let(:partner) { Partner.create! name: 'Alpha Partner', placecal_id: 100 }

    let(:geo_1) {
      GeoEnclosure.create!(
        name: 'Alpha Ward',
        ons_id: 'X000',
        ons_version: 202020,
        ons_type: 'ward'
      )
    }

    let(:geo_2) {
      GeoEnclosure.create!(
        name: 'Beta Ward',
        ons_id: 'X001',
        ons_version: 202020,
        ons_type: 'ward'
      )
    }

    def create_events_for_partner(count, id_offset, time_offset, geo=nil)
      count.times do |n|
        event = partner.events.create!(
          name: 'Beta event',
          address_ward: geo
        )

        event.event_instances.create!(
          starts_at: FakeTime::TODAY + time_offset,
          placecal_id: id_offset + n
        )
      end
    end

    before :each do
      create_events_for_partner 4, 200, 0
      create_events_for_partner 2, 300, 1.day
      create_events_for_partner 3, 400, 2.days, geo_1
      create_events_for_partner 1, 500, 3.days
      create_events_for_partner 4, 600, 4.days, geo_2
      create_events_for_partner 5, 700, 5.days
      create_events_for_partner 1, 800, 6.days
    end

    context 'with no filtering active' do
      it 'shows a list of events, grouped by day' do
        travel_to FakeTime::TODAY do
          visit "/events"

          expect(page).to have_selector('h1', text: 'Events')
          expect(page).to have_selector('.events-listing h2', count: 7)
          expect(page).to have_selector('.events-listing p', count: 20)
        end
      end
    end

    context 'with filtering' do
      it 'can show events on only one day' do
        travel_to FakeTime::TODAY do
          visit "/events"
          click_link 'Monday 3rd June, 2024'
          expect(page).to have_selector('h1', text: 'Events on Monday 3rd June, 2024')
          expect(page).to have_selector('.events-listing p', count: 1)
        end
      end
    end

    context 'with location filtering' do
      it 'shows only events in that location' do
        travel_to FakeTime::TODAY do
          visit '/'
          click_link 'Events'
          # puts page.body

          expect(page).to have_selector('.events-listing p', count: 20)

          # do the filtering
          within '.events-listing p:nth-child(10)' do
            click_link 'Alpha Ward'
          end

          expect(page).to have_selector('.events-listing p', count: 3)
          expect(page).to have_selector('h1', text: 'Events in Alpha Ward')

          # reset
          click_link 'Show events anywhere'
          expect(page).to have_selector('.events-listing p', count: 20)
          expect(page).to have_selector('h1', text: 'Events')
        end
      end
    end
  end
end
