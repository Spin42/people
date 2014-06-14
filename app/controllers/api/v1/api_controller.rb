class Api::V1::ApiController < ActionController::Base

  before_filter :authenticate_api!
  respond_to :json

  private

  def authenticate_api!
    render(nothing: true, status: 403) unless params[:token] == ENV["API_TOKEN"]
  end

end
