module Admin
  class MenuItemsController < ApplicationController
    before_action :set_menu_item, only: [:update, :toggle_stock, :destroy]

    def index
      @menu_items = MenuItem.all.order(created_at: :desc)
      @menu_item = MenuItem.new
    end

    def create
      @menu_item = MenuItem.new(menu_item_params)
      if @menu_item.save
        redirect_to admin_menu_items_path, notice: "Menu item successfully created."
      else
        @menu_items = MenuItem.all.order(created_at: :desc)
        render :index, status: :unprocessable_entity
      end
    end

    def update
      if @menu_item.update(menu_item_params)
        redirect_to admin_menu_items_path, notice: "Menu item updated successfully."
      else
        @menu_items = MenuItem.all.order(created_at: :desc)
        render :index, status: :unprocessable_entity
      end
    end

    def toggle_stock
      # Safely toggle whichever stock column your model uses
      current_status = @menu_item.respond_to?(:in_stock) ? @menu_item.in_stock : @menu_item.available
      new_status = !current_status
      
      if @menu_item.respond_to?(:in_stock)
        @menu_item.update(in_stock: new_status)
      else
        @menu_item.update(available: new_status)
      end

      redirect_to admin_menu_items_path, notice: "#{@menu_item.name} stock status updated."
    end

    def destroy
      @menu_item.destroy
      redirect_to admin_menu_items_path, notice: "Menu item deleted."
    end

    private

    def set_menu_item
      @menu_item = MenuItem.find(params[:id])
    end

    def menu_item_params
      params.require(:menu_item).permit(:name, :price, :description, :available, :in_stock, :category_id, :image)
    end
  end
end