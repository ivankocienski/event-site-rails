class Event < ApplicationRecord
  belongs_to :partner
  alias_method :organizer, :partner

  belongs_to :address_ward, 
    foreign_key: :address_geo_enclosure_id,
    class_name: 'GeoEnclosure',
    optional: true

  has_many :event_instances, dependent: :destroy

  class EventAddress
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

  def address
    @address ||= EventAddress.new(self)
  end
end
