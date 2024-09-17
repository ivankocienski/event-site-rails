class EventInstance < ApplicationRecord
  belongs_to :event

#  these scopes could be here?
#  scope :from_day_onward, lambda { |epoch| 
#    where "date(starts_at) >= date(?)", epoch
#  }
#
#  scope :on_day, lambda { |day| 
#    where "date(starts_at) = date(?)", day
#  }
#
#  scope :before_date, lambda { |day|
#    where "date(starts_at) < date(?)", day
#  }
end
