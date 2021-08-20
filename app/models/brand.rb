class Brand < ApplicationRecord
  has_many :cars, dependent: :destroy
  has_many :user_preferred_brands, dependent: :destroy
end
