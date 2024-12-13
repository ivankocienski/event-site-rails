
require 'rails_helper'

RSpec.describe PartnerUpdater do

  let(:fields) {
    {
      name: 'zeta',
      summary: 'summary of zeta',
      description: 'longer description of alpha',
      placecal_id: 123,
      contact_email: 'beta',
      contact_telephone: 'cappa',
      url: 'delta',
      address_street: 'epsilon',
      address_postcode: 'gamme',
      logo_url: 'mu'
    }
  }

  context 'with new partner' do
    it 'creates a partner' do
      expect {
        partner = PartnerUpdater.new(Partner.new)
        partner.update_fields fields

        partner.save!
      }.to change { Partner.count }.from(0).to(1)
    end
  end

  describe '#update_fields' do

    it 'sets field values' do
      updater = PartnerUpdater.new(Partner.new)
      updater.update_fields fields

      updater.save!

      partner = Partner.last
      fields.each do |name, value|
        expect(partner[name]).to eq value
      end
    end
  end

  describe '#render_description_html' do
    it 'is populated' do
      updater = PartnerUpdater.new(Partner.new)
      updater.update_and_save fields

      partner = Partner.last
      expected_html = "<p>longer description of alpha</p>\n"
      expect(partner.description_html).to eq expected_html
    end
  end

  describe '#scan_for_keywords' do
    before(:each) do
      %w[alpha beta cappa delta epsilon foxtrot].each do |kw_text|
        Keyword.create! name: kw_text
      end
    end

    it 'applies keywords correctly' do
      new_fields = fields.dup
      new_fields[:description] = 'Alpha beta cappa'

      updater = PartnerUpdater.new(Partner.new)
      updater.update_and_save new_fields

      partner = Partner.last
      expect(partner.keywords.count).to eq 3
    end

    context 'updating partner' do
      before :each do
        new_fields = fields.dup
        new_fields[:description] = 'Alpha beta cappa'

        updater = PartnerUpdater.new(Partner.new)
        updater.update_and_save new_fields
      end

      it 'adds new keywords' do
        new_fields = fields.dup
        new_fields[:description] = 'Alpha delta beta epsilon cappa'

        partner = Partner.last
        updater = PartnerUpdater.new(partner)
        updater.update_and_save new_fields

        partner.reload
        expect(partner.keywords.count).to eq 5
      end

      it 'leaves keywords that have not changed' do
        new_fields = fields.dup
        new_fields[:description] = 'Alpha beta cappa'

        partner = Partner.last
        updater = PartnerUpdater.new(partner)
        updater.update_and_save new_fields

        partner.reload
        expect(partner.keywords.count).to eq 3
        expect(partner.keywords.order(:name).pluck(:name)).to eq %w[alpha beta cappa]
      end

      it 'removes keywords no longer present' do
        new_fields = fields.dup
        new_fields[:description] = 'cappa epsilon delta'

        partner = Partner.last
        updater = PartnerUpdater.new(partner)
        updater.update_and_save new_fields

        partner.reload
        expect(partner.keywords.count).to eq 3
        expect(partner.keywords.order(:name).pluck(:name)).to eq %w[cappa delta epsilon]
      end
    end
  end

  describe '#reindex_text_fields'

  describe '#lookup_postcode'
end

