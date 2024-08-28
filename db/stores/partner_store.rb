
module PartnerStore
  def self.partners
    @partners || []
  end

  def self.load_from_fixture(path)
    Rails.logger.info "Loading partner data from #{path}"
    data = JSON.parse(File.open(path).read)
    @partners = data['data']['partnersByTag'].map { |partner_data| Partner.new(partner_data) }
  end
end

