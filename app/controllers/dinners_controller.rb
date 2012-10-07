class DinnersController < ApplicationController
  def index
    @dinners = Dinner.all
    @dinner  = @dinners[rand(@dinners.size)]
  end

  def new
    @dinner = Dinner.new
  end

  def create
    @dinner = Dinner.new(params[:dinner])
    @dinner.save
    redirect_to dinners_path
  end

  def edit
    @dinner = Dinner.find(params[:id])
  end

  def update
    @dinner = Dinner.find(params[:id])
    @dinner.update_attributes(params[:dinner])
    redirect_to dinners_path
  end

  def destroy
    @dinner = Dinner.find(params[:id])
    @dinner.destroy
    redirect_to dinners_path
  end
end
