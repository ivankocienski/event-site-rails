class Keyword < ApplicationRecord
  has_many :partner_keywords
  has_many :partners, through: :partner_keywords

  validates :name, presence: true, uniqueness: true
end
