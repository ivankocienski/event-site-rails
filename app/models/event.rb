class Event < ApplicationRecord
  belongs_to :partner
  alias_method :organizer, :partner

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

  scope :from_day_onward, lambda { |epoch| 
    joins(:event_instances)
      .where("date(event_instances.starts_at) >= date(?)", epoch)
  }

  scope :on_day, lambda { |day| 
    joins(:event_instances)
      .where("date(event_instances.starts_at) = date(?)", day)
  }

  scope :before_date, lambda { |day|
    joins(:event_instances)
      .where("date(event_instances.starts_at) < date(?)", day)
  }
end
