class DinnersController < ApplicationController
  def index
    @dinner = Dinner.all
  end

  def new
    @dinner = Dinner.new
  end

  def create
    @dinner = Dinner.new(params[:dinner])
    @dinner.save
    redirect_to dinners_path
  end
end
