class Partner < ApplicationRecord

  has_many :events

  has_many :partner_keywords, dependent: :destroy
  has_many :keywords, through: :partner_keywords

  belongs_to :address_ward, 
    foreign_key: :address_geo_enclosure_id,
    class_name: 'GeoEnclosure',
    optional: true

  scope :with_fuzzy_name, lambda { |name_string|
    name_string = name_string.to_s.gsub(/\s+/, '') # remove whitespace
    return none if name_string.blank?

    name_pattern = name_string
      .chars
      .map { |ch| sanitize_sql(ch) }
      .join('%')

    where('name LIKE ?', "%#{name_pattern}%")
  }

  scope :with_keyword, lambda { |keyword|
    return all if keyword.blank?

    joins(:partner_keywords)
      .where(partner_keywords: { keyword_id: keyword.id })
  }

  scope :with_slug, lambda { |slug_text|
    return none unless slug_text =~ /^(\d+)[\w\-]*$/

    where id: $1
  }

  scope :in_geo_enclosure, lambda { |geo_enclosure|
    return all if geo_enclosure.blank?

    return where(address_geo_enclosure_id: geo_enclosure.id) if geo_enclosure.ward_level?

    all # TODO is contained within ward set
  }

  def slug
    ([ id ] + name.downcase.split(/\W+/)).join('-')
  end

  class PartnerAddress
    attr_reader :street_address
    attr_reader :post_code
    attr_reader :ward

    def initialize(from)
      @street_address = from.address_street
      @post_code = from.address_postcode
      @ward = from.address_ward
    end

    def present?
      street_address.present? || post_code.present?
    end

    def to_s
      [ street_address, post_code ].keep_if(&:present?).join(', ')
    end
  end

  class PartnerContact
    attr_reader :email
    attr_reader :telephone

    def initialize(from)
      @email = from.contact_email
      @telephone = from.contact_telephone
    end

    def present?
      email.present? || telephone.present?
    end
  end

  def address
    @address ||= PartnerAddress.new(self)
  end

  def contact
    @contact ||= PartnerContact.new(self)
  end

end
