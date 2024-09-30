class GeoEnclosure < ApplicationRecord
  has_ancestry

  def ward_level?
    ons_type == 'ward'
  end
end
