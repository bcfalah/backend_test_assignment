class Car < ApplicationRecord
  belongs_to :brand

  def price_in_range
    attributes['price_in_range']
  end

  def rank_score
    attributes['rank_score']
  end
end
