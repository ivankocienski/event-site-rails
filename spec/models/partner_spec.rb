require 'rails_helper'

describe 'Partner' do
  context 'class' do
    context '::count' do
      it 'returns count of all partners' do
        expect(Partner.count).to eq 65
      end
    end

    context '::find_all_by_name' do
      it 'returns partners, ordered by name' do
        found = Partner.find_all_by_name

        expect( found.first.name < found.last.name ).to be true
      end
    end
    
    context '::find_by_id' do
      it 'returns a Partner if found' do
        found = Partner.find_by_id(133)
        expect(found).to be_a(Partner)
      end

      it 'returns nil for missing ID' do
        found = Partner.find_by_id(123456)
        expect(found).to be nil
      end
    end

    context '::find_by_name_fuzzy' do
      it 'fuzzy finds by name' do
        found = Partner.find_by_name_fuzzy('hox')

        expect(found.length).to be 1
      end

      it 'returns empty iterator on empty inputs' do
        found = Partner.find_by_name_fuzzy("")

        expect(found.length).to be 0
      end

    end
  end
end
