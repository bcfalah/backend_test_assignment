module Clients
  class CarsRecommendationApiClient < BaseApiClient
    attr_accessor :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def get_recommended_cars
      # cache response for each user, expires at end of day
      expires_in_seconds = Time.current.end_of_day - Time.current
      Rails.cache.fetch("#{user_id}/recommended_cars", expires_in: expires_in_seconds) do
        perform_get_request(recommended_cars_url, user_id: user_id)
      end
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
