
require 'rails_helper'

RSpec.describe "Events", type: :feature do

  context 'index' do
    let(:partner) { Partner.create! name: 'Alpha', placecal_id: 100 }

    before :each do
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
