class CarsController < ApplicationController
  before_action :set_user, only: [:recommended]

  def recommended
    @cars = cars_recommendation_service.get_recommendations
    render json: @cars.page(recommendations_page).per(ENV['RECOMMENDED_CARS_PER_PAGE'])
  end

  private

  def cars_recommendation_service
    @cars_recommendation_service ||= CarsRecommendationService.new(
      @user,
      recommendations_params[:query],
      recommendations_params[:price_min],
      recommendations_params[:price_max]
    )
  end

  def set_user
    @user = User.find(recommendations_params[:user_id])
  end

  def recommendations_params
    params.permit(:user_id, :query, :price_min, :price_max, :page)
  end

  def recommendations_page
    recommendations_params[:page] || 1
  end
end
