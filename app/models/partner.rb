class Partner

  attr_reader :id
  attr_reader :name
  attr_reader :summary
  attr_reader :description
  attr_reader :url
  attr_reader :logo_url
  attr_reader :organiser_id

  attr_reader :address
  attr_reader :contact

  class PartnerAddress
    attr_reader :street_address
    attr_reader :post_code

    def initialize(from)
      return unless from.is_a?(Hash)
      @street_address = from['streetAddress']
      @post_code = from['postalCode']
    end
  end

  class PartnerContact
    attr_reader :email
    attr_reader :telephone

    def initialize(from)
      return unless from.is_a?(Hash)
      @email = from['email']
      @telephone = from['telephone']
    end
  end

  def initialize(data)
    return unless data.is_a?(Hash)
    @id = data['id'].to_i
    @name = data['name']
    @summary = data['summary']
    @description = data['description']
    @logo_url = data['logo_url']

    @address = PartnerAddress.new(data['address'])
    @contact = PartnerContact.new(data['contact'])
  end

  def self.load_from_fixture(path)
    Rails.logger.info "Loading partner data from #{path}"
    data = JSON.parse(File.open(path).read)
    @partners = data['data']['partnersByTag'].map { |partner_data| Partner.new(partner_data) }
  end

  def self.count
    (@partners || []).count
  end

  def self.find_all_by_name
    (@partners || []).sort { |a, b| a.name <=> b.name }
  end

  def self.find_by_name_fuzzy(name_string)
    name_string = name_string.to_s.gsub(/\s+/, '') # remove whitespace
    return [] if name_string.blank?

    name_pattern = name_string
      .chars
      .map { |ch| Regexp.escape(ch) }
      .join('.*')

    name_regex = Regexp.new(name_pattern, Regexp::IGNORECASE)

    (@partners || []).filter { |partner| name_regex.match(partner.name) }
  end

  def self.find_by_id(want_id)
    return unless want_id.present?
    want_id = want_id.to_i
    (@partners || []).find { |partner| partner.id == want_id }
  end
end


