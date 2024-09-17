require 'rails_helper'

RSpec.describe Event, type: :model do

  context '(date scope)' do
    def create_event(start, placecal_id, partner)
      Event.transaction do

        event = Event.create! partner: partner
        event.event_instances.create!(
          starts_at: start, 
          placecal_id: placecal_id
        )
      end
    end

    before :each do
      partner = Partner.create! name: 'Alpha', placecal_id: 200

      # 1st of june
      create_event Time.new(2000, 6, 1, 10, 30), 100, partner
      create_event Time.new(2000, 6, 1, 12, 30), 100, partner

      # 4th of june
      create_event Time.new(2000, 6, 4, 9, 0), 100, partner
      create_event Time.new(2000, 6, 4, 12, 0), 100, partner
      create_event Time.new(2000, 6, 4, 17, 30), 100, partner

      # 10th of june
      create_event Time.new(2000, 6, 10, 8, 0), 100, partner
      create_event Time.new(2000, 6, 10, 10, 0), 100, partner

      # 1st of july
      create_event Time.new(2000, 7, 1, 10, 30), 100, partner
    end

    # june 4th at 4.25pm
    let(:epoch) { Time.new(2000, 6, 4, 16, 25) }

    context '::from_day_onward' do
      it 'returns events in future of epoch (including all events on same day)' do
        found = Event.from_day_onward(epoch)
        expect(found.count).to eq 6
      end
    end

    context '::on_day' do
      it 'returns events only on that day' do
        found = Event.on_day(epoch)
        expect(found.count).to eq 3
      end
    end

    context '::before_date' do
      it 'returns all events *before* date' do
        found = Event.before_date(epoch)
        expect(found.count).to eq 2
      end
    end

    

  end
end
