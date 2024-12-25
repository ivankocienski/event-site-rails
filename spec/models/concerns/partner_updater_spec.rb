
require 'rails_helper'

RSpec.describe PartnerUpdater do
  GEO_DATA_SUBSET_PATH = fixture_paths.first.join('geo-data-subset.json.zip').freeze

  let(:postcode_db) { PartnerUpdater::PostcodeLookup.new(GEO_DATA_SUBSET_PATH) }

  before :each do
    search_client.indices.delete(index: 'partners')
    search_client.indices.create(index: 'partners')
  end

  describe PartnerUpdater::PostcodeLookup do
    context '#lookup_postcode' do

      it 'returns a GeoLocation if it exists' do
        output = postcode_db.lookup_postcode('AB1 0AR')
        expect(output).to be_a(GeoEnclosure)
      end

      it 'creates enclosures that don\'t exist' do
        expect {
          postcode_db.lookup_postcode 'AB1 0AR'
        }.to change { GeoEnclosure.count }.by 3
      end

      it 'returns nil when not found' do
        output = postcode_db.lookup_postcode('XYZ 123')
        expect(output).to be nil
      end
    end
  end

  #
  # updater unit tests...
  #

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
      address_postcode: '',
      logo_url: 'mu'
    }
  }
  

  context 'with new partner' do
    it 'creates a partner' do
      expect {
        partner = PartnerUpdater.new(Partner.new, postcode_db, search_client)
        partner.update_fields fields

        partner.save!
      }.to change { Partner.count }.from(0).to(1)
    end
  end

  describe '#update_fields' do
    it 'sets field values' do
      updater = PartnerUpdater.new(Partner.new, postcode_db, search_client)
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
      updater = PartnerUpdater.new(Partner.new, postcode_db, search_client)
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

      updater = PartnerUpdater.new(Partner.new, postcode_db, search_client)
      updater.update_and_save new_fields

      partner = Partner.last
      expect(partner.keywords.count).to eq 3
    end

    context 'updating partner\'s keyword relations' do
      before :each do
        new_fields = fields.dup
        new_fields[:description] = 'Alpha beta cappa'

        updater = PartnerUpdater.new(Partner.new, postcode_db, search_client)
        updater.update_and_save new_fields
      end

      it 'adds new keywords' do
        new_fields = fields.dup
        new_fields[:description] = 'Alpha delta beta epsilon cappa'

        partner = Partner.last
        updater = PartnerUpdater.new(partner, postcode_db, search_client)
        updater.update_and_save new_fields

        partner.reload
        expect(partner.keywords.count).to eq 5
      end

      it 'leaves keywords that have not changed' do
        new_fields = fields.dup
        new_fields[:description] = 'Alpha beta cappa'

        partner = Partner.last
        updater = PartnerUpdater.new(partner, postcode_db, search_client)
        updater.update_and_save new_fields

        partner.reload
        expect(partner.keywords.count).to eq 3
        expect(partner.keywords.order(:name).pluck(:name)).to eq %w[alpha beta cappa]
      end

      it 'removes keywords no longer present' do
        new_fields = fields.dup
        new_fields[:description] = 'cappa epsilon delta'

        partner = Partner.last
        updater = PartnerUpdater.new(partner, postcode_db, search_client)
        updater.update_and_save new_fields

        partner.reload
        expect(partner.keywords.count).to eq 3
        expect(partner.keywords.order(:name).pluck(:name)).to eq %w[cappa delta epsilon]
      end
    end
  end

  describe '#reindex_text_fields' do
    it 'rescans partner' do
      new_fields = fields.dup

      updater = PartnerUpdater.new(Partner.new, postcode_db, search_client)
      updater.update_and_save new_fields
      sleep 1 # ugh

      found = Partner.with_fuzzy_string('description of alpha').first

      expect(found).to be_a(Partner)
    end
  end

  describe '#lookup_postcode' do
    it 'assigns new postcode' do
      new_fields = fields.dup
      new_fields[:address_postcode] = 'AB1 0LP'

      updater = PartnerUpdater.new(Partner.new, postcode_db, search_client)
      updater.update_and_save new_fields

      partner = updater.partner
      expect(partner.address_ward).to be_a(GeoEnclosure)
    end

    it 'changes existing postcode' do
      fake_enclosure = GeoEnclosure.create!(
        name: 'Fake Enclosure',
        ons_id: 'FF999999',
        ons_version: '2002',
        ons_type: 'ward'
      )

      new_fields = fields.dup
      new_fields[:address_postcode] = 'AB1 0LP'
      new_fields[:address_geo_enclosure_id] = fake_enclosure.id
      partner = Partner.create!(new_fields)

      updater = PartnerUpdater.new(partner, postcode_db, search_client)

      update_fields = fields.dup
      update_fields[:address_postcode] = 'AB1 0DR'
      updater.update_and_save update_fields

      partner.reload
      expect(partner.address_ward).to be_a GeoEnclosure
      expect(partner.address_ward).not_to eq fake_enclosure
    end

    it 'removes postcode when not present' do
      new_fields = fields.dup
      new_fields[:address_postcode] = 'AB1 0LP'

      updater = PartnerUpdater.new(Partner.new, postcode_db, search_client)
      updater.update_and_save new_fields

      partner = updater.partner
      expect(partner.address_ward).to be_a GeoEnclosure

      # remove postcode
      update_fields = fields.dup
      update_fields[:address_postcode] = ''

      another_updater = PartnerUpdater.new(partner, postcode_db, search_client)
      another_updater.update_and_save update_fields

      partner.reload
      expect(partner.address_ward).to be nil
    end

    pending '(TODO) does something with unknown postcodes'

  end

  def search_client
    @search_client ||= OpenSearch::Client.new(
      host: ENV['OPENSEARCH_URL'],
      user: ENV['OPENSEARCH_USER'],
      password: ENV['OPENSEARCH_PASSWORD'],
      transport_options: { ssl: { verify: false } }
    )
  end
end

