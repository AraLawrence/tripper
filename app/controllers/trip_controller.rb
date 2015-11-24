require 'rest-client'

class TripController < ApplicationController
  before_action :current_user

  def index
  end
 
  # generate change page
  def change
    @trip = Trip.find(params[:id])
    @destinations = Trip.find(params[:id]).destinations.order(:id)
    @coord = Trip.find(params[:id]).latlngs
  end

  def create
    trip= Trip.create trip_params
    user = @current_user.id
    trip = User.find(user).trips.create trip_params
    @trip = trip
    gflash :success => "Trip created!"
    redirect_to trip_new_path(trip.id)
  end

  def add
    trip = Trip.find(params[:id])
    trip.destinations.create dest_params
    redirect_to trip_new_path(params[:id])
  end

  def redest
    trip = Trip.find(params[:id])
    trip.destinations.find(params[:dest]).update dest_params
    redirect_to trip_change_path(params[:id])
  end

  def pseudonew
    lat = 0
    long = 0

    @client = GooglePlaces::Client.new(ENV["PLACES_KEY"])
    @spotList = @client.spots(lat, long, :radius => 3219, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    # @spotList.sort! { |a,b| a.price_level <=> b.price_level}
    @spotList.sort! { |a,b| b.rating <=> a.rating }

    @gmap = ENV['GOOGLE_DIR']
    @trip = Trip.find params[:id]
    @destination = @trip.destinations.find(params[:dest])
  end

  def pseudoupdate
    trip = Trip.find params[:id]
    trip.latlngs.create lat:params['lat'], long:params['lng']
    render :js => "window.location = '/trip/" + params[:id] + "/destedit/" + params[:dest] + "'"
  end

  def destedit
    trip = Trip.find params[:id]
    lat = trip.latlngs.last['lat']
    long =  trip.latlngs.last['long']
    @client = GooglePlaces::Client.new(ENV["PLACES_KEY"])
    @spotList = @client.spots(lat, long, :radius => 3219, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    list = []
    @spotList.each do |d|
      if d.rating
        list.push(d)
      end
    end
    @spotList = list.sort! { |a,b| b.rating <=> a.rating }
    @gmap = ENV['GOOGLE_DIR']
    @trip = Trip.find params[:id]
    @destination = Destination.new
  end

  def new

    puts @user
    lat = 0
    long = 0

    @client = GooglePlaces::Client.new(ENV["PLACES_KEY"])
    @spotList = @client.spots(lat, long, :radius => 3219, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    @spotList.sort! { |a,b| b.rating <=> a.rating }
    @destinations = Trip.find(params[:id]).destinations

    @gmap = ENV['GOOGLE_DIR']
    @trip = Trip.find params[:id]   
  end

  def edit
    trip = Trip.find params[:id]
    lat = trip.latlngs.last['lat']
    long =  trip.latlngs.last['long']
    @client = GooglePlaces::Client.new(ENV["PLACES_KEY"])
    @spotList = @client.spots(lat, long, :radius => 3219, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    list = []
    @spotList.each do |d|
      if d.rating
        list.push(d)
      end
    end
    @spotList = list.sort! { |a,b| b.rating <=> a.rating }
    @gmap = ENV['GOOGLE_DIR']
    @trip = Trip.find params[:id]
    @destination = Destination.new
  end

  def triplist
    @trip = User.find(@current_user.id).trips
    # @trip = User.find_by_id(1).trips
    @coords = Latlng.all 

  end 

  def update
    trip = Trip.find params[:id]
    trip.latlngs.create lat:params['lat'], long:params['lng']
    render :js => "window.location = '/trip/" + params[:id] + "/edit'"
  end

  def delete
    dest = Destination.find(params[:id])
    trip = Trip.find(params[:dest])

    if trip
      trip.destinations.delete(dest)
      dest.delete
    end

    redirect_to trip_change_path(params[:dest])
  end

  def destroy
    trip = Trip.find(params[:id])
    latlng = Latlng.where(trip_id: params[:id])

    if trip
    trip.latlngs.destroy(latlng)
    trip.destroy
  end  
    redirect_to trip_triplist_path
  end

  private 
  
  def dest_params
    params.require(:destination).permit(:place, :url)
  end

  def trip_params
    params.require(:trip).permit(:start_point, :end_point, :trip_name)
  end  
end
