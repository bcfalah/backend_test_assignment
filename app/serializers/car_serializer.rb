class CarSerializer < ActiveModel::Serializer
  attributes :id, :price, :rank_score, :model, :label

  belongs_to :brand

  def label
    price_in_range = object.price_in_range
    return nil if price_in_range.nil?
    price_in_range ? 'perfect_match' : 'good_match'
  end
end
