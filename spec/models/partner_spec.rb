require 'rails_helper'

RSpec.describe Partner, type: :model do
  describe '::find_by_name_fuzzy' do
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
        name: 'Fine carpet Co.',
        placecal_id: 102
      )
    end

    it 'finds names with a fuzzy string match' do
      # in any part of the string
      result = Partner.find_by_name_fuzzy('burg')
      expect(result.first.placecal_id).to be 101

      # case insensitive
      result = Partner.find_by_name_fuzzy('alpha')
      expect(result.first.placecal_id).to be 100

      # deals with whitespace
      result = Partner.find_by_name_fuzzy("  \t\r\n")
      expect(result.count).to be 0
    end

  end
end
