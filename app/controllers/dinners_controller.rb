class DinnersController < ApplicationController
  def index
    @dinner = Dinner.all
  end
end
