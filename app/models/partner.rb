class Partner

  attr_reader :id
  attr_reader :name
  attr_reader :summary
  attr_reader :description
  attr_reader :url
  attr_reader :logo_url

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

    def present?
      @street_address.present? || @post_code.present?
    end

    def to_s
      [ @street_address, @post_code ].keep_if(&:present?).join(', ')
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

    def present?
      @email.present? || @telephone.present?
    end
  end

  def initialize(data)
    return unless data.is_a?(Hash)
    @id = data['id'].to_i
    @name = data['name']
    @summary = data['summary']
    @description = data['description']
    @logo_url = data['logo']
    @url = data['url']

    @address = PartnerAddress.new(data['address'])
    @contact = PartnerContact.new(data['contact'])
  end

  def events
    @events ||= Event.find_by_organizer_id(@id)
  end

  def self.count
    PartnerStore.partners.count
  end

  def self.find_all_by_name
    PartnerStore.partners.sort { |a, b| a.name <=> b.name }
  end

  def self.find_by_name_fuzzy(name_string)
    name_string = name_string.to_s.gsub(/\s+/, '') # remove whitespace
    return [] if name_string.blank?

    name_pattern = name_string
      .chars
      .map { |ch| Regexp.escape(ch) }
      .join('.*')

    name_regex = Regexp.new(name_pattern, Regexp::IGNORECASE)

    PartnerStore.partners.filter { |partner| name_regex.match(partner.name) }
  end

  def self.find_by_id(want_id)
    return unless want_id.present?
    want_id = want_id.to_i
    PartnerStore.partners.find { |partner| partner.id == want_id }
  end
end


