class Car < ApplicationRecord
  belongs_to :brand

  attr_accessor :rank_score

  def price_in_range
    attributes['price_in_range']
  end
end
