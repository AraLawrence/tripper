class TripController < ApplicationController
  before_action :is_authenticated?, except: [:index, :show]
   
  def index
  end

  def create
  end

  def new
  end

  def edit
  end

  def show
  end

  def update
  end

  def destroy
  end
end
