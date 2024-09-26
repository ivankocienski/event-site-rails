require 'rails_helper'

RSpec.describe Partner, type: :model do
  describe '::with_fuzzy_name' do
    before :each do
      Partner.create!(
        name: 'Alpha partner',
        placecal_id: 100
      )

      Partner.create!(
        name: 'bobs burgers',
        placecal_id: 101
      )

      Partner.create!(
        name: 'fine carpet co.',
        placecal_id: 102
      )
    end

    it 'finds names with a fuzzy string match' do
      # in any part of the string
      result = Partner.with_fuzzy_name('burg').first
      expect(result.placecal_id).to be 101

      # case insensitive
      result = Partner.with_fuzzy_name('alpha').first
      expect(result.placecal_id).to be 100

      # deals with whitespace
      result = Partner.with_fuzzy_name("  \t\r\n").first
      expect(result).to be nil
    end
  end

  describe '::with_keyword' do
    let(:keyword) { Keyword.create!(name: 'alpha') }
    let(:other_keyword) { Keyword.create!(name: 'beta') }

    before :each do
      p1 = Partner.create!(
        name: 'First partner',
        placecal_id: 100
      )

      p1.keywords << keyword

      p2 = Partner.create!(
        name: 'Second partner',
        placecal_id: 101
      )

      p2.keywords << other_keyword

      p3 = Partner.create!(
        name: 'Third partner',
        placecal_id: 102
      )
    end

    it 'only finds partners with that tagged with keyword' do
      found = Partner.with_keyword(keyword)
      expect(found.count).to be 1
    end
  end

  # if i were paranoid i'd also put in a test covering
  # the use of both filters simultaneously - but this 
  # could be tested in an integration test

  context 'slugging' do
    context '#slug' do
      it 'generates a slug from the name/id' do
        p1 = Partner.create!(name: 'A partner name', placecal_id: 100)
        expect(p1.slug).to eq "#{p1.id}-a-partner-name"

        # deals with non-word-characters
        p2 = Partner.create!(name: 'A?! partner123 name $^; with~bad"letters', placecal_id: 101)
        expect(p2.slug).to eq "#{p2.id}-a-partner123-name-with-bad-letters"
      end
    end

    context '::with_slug' do
      it 'finds partners based on slug' do

        new_partner = Partner.create!(name: 'A partner name', placecal_id: 100)

        # find by full slug
        found_partner_1 = Partner.with_slug("#{new_partner.id}-a-partner-name").first
        expect(found_partner_1).to eq new_partner

        # with just ID
        found_partner_2 = Partner.with_slug(new_partner.id.to_s).first
        expect(found_partner_2).to eq new_partner

        # finds nothing without the ID bit
        found_partner_3 = Partner.with_slug('a-partner-name').first
        expect(found_partner_3).to be nil
      end
    end
  end

  context 'address_geo_enclosure' do
    let(:geo_enclosure) {
      GeoEnclosure.create! name: 'alpha', ons_id: 'E001', ons_version: 2000, ons_type: 'ward'
    }

    it 'can be setup' do
      partner = Partner.create! name: 'Alpha partner', placecal_id: 123
      expect(partner.address_ward).to be nil

      partner.address_ward = geo_enclosure
      partner.save!
    end

    it 'can be read' do
      partner = Partner.create!(name: 'Alpha partner', placecal_id: 123, address_ward: geo_enclosure)
      expect(partner.address_ward).to be_a(GeoEnclosure)
    end
  end
end
