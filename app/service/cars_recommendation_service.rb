class CarsRecommendationService
  attr_reader :user, :brand_name, :price_min, :price_max

  def initialize(user, brand_name, price_min, price_max)
    @user = user
    @brand_name = brand_name
    @price_min = price_min
    @price_max = price_max
  end

  def get_recommendations
    # TODO make a query joining with preferred_brands and bring all cars of that brand
    # then select also a field with case (if preferred_price_range.include?(car.price) then 1 else 0)
    # and order by that field DESC
    # After this collection, add the top 5 cars suggested by external recommendation service API
    # After this, add all other cars sorted by price (ASC).
    # TODO what to do with pagination?
    Car.select("cars.*, preferred_price_range::int8range @> cars.price::bigint as price_in_range")
       .joins(brand: { user_preferred_brands: :user })
       .where(user: { id: user.id })
       .order('price_in_range DESC')
  end

  # [
  #   {
  #     "id": <car id>
  #     "brand": {
  #       id: <car brand id>,
  #       name: <car brand name>
  #     },
  #     "price": <car price>,
  #     "rank_score": <rank score of external API or nil>,
  #     "model": <car model>,
  #     "label": <perfect_match|good_match|nil>
  #   },
  #   ...
  # ]
end