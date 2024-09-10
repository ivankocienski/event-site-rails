require 'rails_helper'

RSpec.describe "Partner show", type: :feature do
  context 'event list' do
    let(:partner) { Partner.create! name: 'London Friend', placecal_id: 100 }

    before :each do
      9.times do |n|
        partner.events.create!(
          name: 'Alpha event',
          starts_at: FakeTime::TODAY,
          placecal_id: 200 + n
        )
      end
    end

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
