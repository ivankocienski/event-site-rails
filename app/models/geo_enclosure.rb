class GeoEnclosure < ApplicationRecord
  has_ancestry

  scope :of_ward_type, lambda {
    where ons_type: 'ward'
  }

  def ward_level?
    ons_type == 'ward'
  end
end
