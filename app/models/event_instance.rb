class EventInstance < ApplicationRecord
  belongs_to :event

  scope :from_day_onward, lambda { |epoch| 
    where "date(starts_at) >= date(?)", epoch
  }

  scope :on_day, lambda { |day| 
    where "date(starts_at) = date(?)", day
  }

  scope :before_date, lambda { |day|
    where "date(starts_at) < date(?)", day
  }

  scope :for_partner, lambda { |partner|
    joins(event: [:partner])
      .where( 'partners.id = ?', partner.id )
  }
end
