require 'rails_helper'

RSpec.describe Event, type: :model do
  context 'address_geo_enclosure' do
    let(:geo_enclosure) {
      GeoEnclosure.create! name: 'alpha', ons_id: 'E001', ons_version: 2000, ons_type: 'ward'
    }
    let(:partner) { Partner.create! name: 'Alpha partner', placecal_id: 123 }

    it 'can be setup' do
      event = Event.create! name: 'Alpha event', partner: partner 
      expect(event.address_ward).to be nil

      event.address_ward = geo_enclosure
      event.save!
    end

    it 'can be read' do
      event = Event.create!(name: 'Alpha event', address_ward: geo_enclosure, partner: partner)
      expect(event.address_ward).to be_a(GeoEnclosure)
    end
  end
end
