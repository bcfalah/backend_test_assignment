class CarsRecommendationService
  attr_reader :user, :brand_name, :price_min, :price_max

  def initialize(user, brand_name, price_min, price_max)
    @user = user
    @brand_name = brand_name
    @price_min = price_min
    @price_max = price_max
  end

  def get_recommendations
    # it is important to use left joins here, so all cars can be retrieved, and not only user's cars
    # price_in_range will be null for cars not preferred by the user

    # it is not the same to put user_id condition on the join or in the where
    base_query = Car.includes(:brand)
      .select("cars.*,
              preferred_price_range::int8range @> cars.price::bigint as price_in_range,
              rank_score")
     .left_outer_joins(brand: :user_preferred_brands )
     .joins("LEFT OUTER JOIN users ON users.id = user_preferred_brands.user_id
            and users.id = #{user.id}")

    base_query = join_with_ai_recommended_cars(base_query)
    base_query = base_query.where("brands.name ilike ?", "%#{brand_name}%") if brand_name.present?
    base_query = base_query.where("price >= ?", price_min) if price_min.present?
    base_query = base_query.where("price <= ?", price_max) if price_max.present?
    base_query.order('price_in_range DESC NULLS LAST, ai_recommended DESC NULLS LAST, price ASC')
  end

  private

  def join_with_ai_recommended_cars(base_query)
    ai_recommended_cars_table = "(values #{ai_recommended_cars_values.join(',')})"
    base_query
      .joins("left join #{ai_recommended_cars_table} as rec_cars(car_id, rank_score, ai_recommended)
              on rec_cars.car_id = cars.id")
  end

  # TODO this could be improved by having custom objects
  def ai_recommended_cars_values
    ai_recommended_cars_values = []
    cars_recommendation_client.get_recommended_cars
    if cars_recommendation_client.request_successful?
      ai_recommended_cars = cars_recommendation_client.response_body.sort_by { |c| c[:rank_score] }.reverse.first(5)
      ai_recommended_cars.each do |car|
        ai_recommended_cars_values << "(#{car[:car_id]}, #{car[:rank_score]}, 1)"
      end
    end
    ai_recommended_cars_values
  end

  def cars_recommendation_client
    @cars_recommendation_client ||= Clients::CarsRecommendationApiClient.new(user.id)
  end
end
