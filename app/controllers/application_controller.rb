class ApplicationController < ActionController::API
  rescue_from ::ActiveRecord::RecordNotFound, with: :render_error

  def render_error(exception)
    render json: {error: exception.message}.to_json, status: 404
  end
end
