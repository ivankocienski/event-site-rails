class Event < ApplicationRecord
  belongs_to :partner
  alias_method :organizer, :partner

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

  # ::find_in_future
  # ::find_on_day
  # ::find_by_id
  # ::find_by_organizer_id
  
  def self.find_in_future(date)
    # FIXME
    #date = date.beginning_of_day
    #where( "date(starts_at) >= date(?)", date ).all
    all
  end

  def self.find_on_day(date)
    all
  end

  def self.find_by_id(want_id)
    where(id: want_id).first
  end

  def self.find_by_organizer_id(organizer_id)
  end
end
