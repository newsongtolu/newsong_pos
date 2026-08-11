class StoreController < ApplicationController
  before_action :persist_fulfillment_params, only: [:index]

  def index
    # Fetch all available menu items/products for customers
    @products = Product.all # Replace with your product model query if scoped
  end

  private

  def persist_fulfillment_params
    # Save to session if present in params, keeping state across requests
    session[:fulfillment] = params[:fulfillment] if params[:fulfillment].present?
    session[:order_id] = params[:order_id] if params[:order_id].present?
  end
end