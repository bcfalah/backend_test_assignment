module Clients
  class CarsRecommendationApiClient < BaseApiClient
    attr_accessor :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def get_recommended_cars
      perform_get_request(recommended_cars_url, user_id: user_id)
      self
    end

    protected

    def base_url
      ENV['CARS_RECOMMENDATION_API_URL']
    end

    def recommended_cars_url
      base_url + '/recomended_cars.json'
    end
  end
end
