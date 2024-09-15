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

end
