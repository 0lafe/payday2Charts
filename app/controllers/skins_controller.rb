class SkinsController < ApplicationController
  def index
    @median_list = JSON.parse(REDIS_CLIENT.get("inventory_value_lb_median"))
    @item_count_list = JSON.parse(REDIS_CLIENT.get("top_item_lb"))
    @individual_item_count_list = JSON.parse(REDIS_CLIENT.get("top_individual_item_lb"))
    @average_price_lb = JSON.parse(REDIS_CLIENT.get("average_price_lb"))
    @median_price_lb = JSON.parse(REDIS_CLIENT.get("median_price_lb"))
    @highest_price_lb = JSON.parse(REDIS_CLIENT.get("highest_price_lb"))
    @item_existance_lb = JSON.parse(REDIS_CLIENT.get("item_existance_lb"))
  end

  def show
    @user = User.find_by(steam_id: params[:id])
  end
end