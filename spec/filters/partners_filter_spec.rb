
require 'rails_helper'

RSpec.describe PartnersFilter, type: :unit do

  let(:geo_enclosure) do
    GeoEnclosure.create!(
      name: 'beta enclosure',
      ons_id: 'abc123',
      ons_version: '100', ons_type: 'ward'
    )
  end

  let(:keyword) { Keyword.create! name: 'alpha' }

  describe 'basic value function' do
    describe '#name_value' do
      it 'is normalized' do
        filter = PartnersFilter.new(name: '  Hello  ')
        expect(filter.name_value).to eq 'Hello'
      end
    end

    describe '#keyword_value' do
      it 'is blank if not set' do
        filter = PartnersFilter.new({})
        expect(filter.keyword_value).to be nil
      end

      it 'is blank if not found' do
        filter = PartnersFilter.new({ keyword: 'alpha'})
        expect(filter.keyword_value).to be nil
      end

      it 'returns keyword object if it exists' do
        keyword # must exist
        filter = PartnersFilter.new({ keyword: 'alpha' })
        expect(filter.keyword_value).to eq keyword
      end
    end

    describe '#geo_value' do
      it 'is blank if not set' do
        filter = PartnersFilter.new({})
        expect(filter.geo_value).to be nil
      end

      it 'is blank if not found' do
        filter = PartnersFilter.new({ geo: 123456 })
        expect(filter.geo_value).to be nil
      end

      it 'returns GeoEnclosure object if it exists' do
        filter = PartnersFilter.new({ geo: geo_enclosure.id })
        expect(filter.geo_value).to eq geo_enclosure
      end
    end

    describe '#active?' do
      it 'is false when no params are present' do
        filter = PartnersFilter.new({})
        expect(filter.active?).to be false

        # names of just whitespace are ignored
        filter = PartnersFilter.new({ name: "  \t\n\r " })
        expect(filter.active?).to be false
      end

      it 'is true if any param value is set (and valid)' do
        filter = PartnersFilter.new({ name: 'hello' })
        expect(filter.active?).to be true

        keyword # must exist
        filter = PartnersFilter.new({ keyword: 'alpha' })
        expect(filter.active?).to be true

        filter = PartnersFilter.new({ geo: geo_enclosure.id })
        expect(filter.active?).to be true
      end
    end

    describe '#empty?' do
      it 'is false if no params are set' do
        filter = PartnersFilter.new({})
        expect(filter.empty?).to be false
      end

      it 'is true if param set but there are no results' do
        filter = PartnersFilter.new({ name: 'alpha' })
        expect(filter.empty?).to be true
      end

      it 'is false if param set and a result is present' do
        partner = Partner.create(
          name: 'Zulu partner',
          placecal_id: 123,
          address_ward: geo_enclosure
        )

        filter = PartnersFilter.new({ geo: geo_enclosure.id })
        expect(filter.empty?).to be false
      end
    end
  end

  describe '#link_to' # TODO

  describe '#search_form' # TODO

  describe '#title_part' # TODO

  describe '#results' do
    let!(:partner_by_name) do
      Partner.create!(
        name: 'Zulu Partner Alpha',
        placecal_id: 100,
      )
    end
      
    let!(:partner_by_keyword) do
      partner = Partner.create!(
        name: 'Zulu partner Beta',
        placecal_id: 200,
      )
      partner.keywords << keyword
      partner
    end

    let!(:partner_by_geo) do
      Partner.create(
        name: 'Zulu partner Cappa',
        placecal_id: 300,
        address_ward: geo_enclosure
      )
    end

    before :each do
      Partner.reindex
    end

    it 'returns all partners when no params given' do
      filter = PartnersFilter.new({ })
      results = filter.result

      expect(results.count).to eq 3
    end

    it 'filters on name' do
      filter = PartnersFilter.new({ name: 'zulu alpha' })
      results = filter.result

      expect(results.count).to eq 1
      expect(results.first).to eq partner_by_name
    end

    it 'filters on keyword' do
      filter = PartnersFilter.new({ keyword: 'alpha' })
      results = filter.result

      expect(results.count).to eq 1
      expect(results.first).to eq partner_by_keyword
    end

    it 'filters on geo' do
      filter = PartnersFilter.new({ geo: geo_enclosure.id })
      results = filter.result

      expect(results.count).to eq 1
      expect(results.first).to eq partner_by_geo
    end
  end
  
end
