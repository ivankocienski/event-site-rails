
require 'rails_helper'

RSpec.describe "Events", type: :feature do

  context 'index' do
    let(:partner) { Partner.create! name: 'Alpha Partner', placecal_id: 100 }

    def create_events_for_partner(count, id_offset, time_offset)
      count.times do |n|
        event = partner.events.create!( name: 'Beta event' )
        event.event_instances.create!(
          starts_at: FakeTime::TODAY + time_offset,
          placecal_id: id_offset + n
        )
      end
    end

    before :each do
      create_events_for_partner 4, 200, 0
      create_events_for_partner 2, 300, 1.day
      create_events_for_partner 3, 400, 2.days
      create_events_for_partner 1, 500, 3.days
      create_events_for_partner 4, 600, 4.days
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
  end
end


__END__

      4.times do |n|
        partner.events.create!(
          name: 'Alpha',
          starts_at: FakeTime::TODAY,
          placecal_id: 200 + n
        )
      end
      2.times do |n|
        partner.events.create!(
          name: 'Alpha',
          starts_at: FakeTime::TODAY + 1.day,
          placecal_id: 300 + n
        )
      end
      3.times do |n|
        partner.events.create!(
          name: 'Alpha',
          starts_at: FakeTime::TODAY + 2.days,
          placecal_id: 400 + n
        )
      end
      1.times do |n|
        partner.events.create!(
          name: 'Alpha',
          starts_at: FakeTime::TODAY + 3.days,
          placecal_id: 500 + n
        )
      end
      4.times do |n|
        partner.events.create!(
          name: 'Alpha',
          starts_at: FakeTime::TODAY + 4.days,
          placecal_id: 600 + n
        )
      end
      5.times do |n|
        partner.events.create!(
          name: 'Alpha',
          starts_at: FakeTime::TODAY + 5.days,
          placecal_id: 700 + n
        )
      end
      1.times do |n|
        partner.events.create!(
          name: 'Alpha',
          starts_at: FakeTime::TODAY + 6.days,
          placecal_id: 800 + n
        )
      end
