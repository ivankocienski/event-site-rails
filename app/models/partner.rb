class Partner < ApplicationRecord

  # TODO
  # PartnerAddress
  # PartnerContact
  # has_many :events
  # ::count
  # ::find_all_by_name
  # ::find_by_name_fuzzy
  # ::find_by_id

  # these behave the same way the non-AR methods do
  def self.find_all_by_name
    order(:name).all
  end

  def self.find_by_name_fuzzy(name)
    all
  end

  def self.find_by_id(id)
    where(id: id).first
  end

  class PartnerAddress
    attr_reader :street_address
    attr_reader :post_code

    def initialize(from)
      @street_address = from.address_street
      @post_code = from.address_postcode
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

  def events
    []
  end

  def address
    @address ||= PartnerAddress.new(self)
  end

  def contact
    @contact ||= PartnerContact.new(self)
  end
end
