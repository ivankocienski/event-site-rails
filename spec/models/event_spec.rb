
require 'rails_helper'

describe 'Event' do
  context 'class' do
    context '::count' do
      it 'returns count of all partners' do
        expect(Event.count).to eq 2900
      end
    end

    context '::find_in_future' do
      # FIXME: use test fixtures and explain magic numbers better
      it 'returns events from a given time' do
        epoch = Time.new(2024, 6, 1)
        found = Event.find_in_future(epoch)
        expect(found.length).to be 1214
      end
    end

    context '::find_on_day' do
      # FIXME: use test fixtures and explain magic numbers better
      it 'returns events on given day' do
        epoch = Time.new(2024, 3, 10)
        found = Event.find_on_day(epoch)
        expect(found.length).to be 5
      end
    end

    context '::find_by_id' do
      it 'returns a Event if found' do
        found = Event.find_by_id(331179)
        expect(found).to be_a(Event)
      end

      it 'returns nil for missing ID' do
        found = Event.find_by_id(123456)
        expect(found).to be nil
      end
    end
  end
end
