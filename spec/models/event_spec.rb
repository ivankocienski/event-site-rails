require 'rails_helper'

RSpec.describe Event, type: :model do

  context '(date scope)' do
    before :each do
      partner = Partner.create! name: 'Alpha', placecal_id: 200

      # 1st of june
      Event.create! starts_at: Time.new(2000, 6, 1, 10, 30), placecal_id: 100, partner: partner
      Event.create! starts_at: Time.new(2000, 6, 1, 12, 30), placecal_id: 100, partner: partner

      # 4th of june
      Event.create! starts_at: Time.new(2000, 6, 4, 9, 0), placecal_id: 100, partner: partner
      Event.create! starts_at: Time.new(2000, 6, 4, 12, 0), placecal_id: 100, partner: partner
      Event.create! starts_at: Time.new(2000, 6, 4, 17, 30), placecal_id: 100, partner: partner

      # 10th of june
      Event.create! starts_at: Time.new(2000, 6, 10, 8, 0), placecal_id: 100, partner: partner
      Event.create! starts_at: Time.new(2000, 6, 10, 10, 0), placecal_id: 100, partner: partner

      # 1st of july
      Event.create! starts_at: Time.new(2000, 7, 1, 10, 30), placecal_id: 100, partner: partner
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
