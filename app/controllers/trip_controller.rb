require 'rest-client'

class TripController < ApplicationController
  before_action :current_user
  before_action :is_authenticated?, except:[:index, :create, :new]

  def index
  end
 
  # generate change page
  def change
    @trip = Trip.find(params[:id])
    @destinations = Trip.find(params[:id]).destinations.order(:id)
    number = @destinations.length
    @coord = Trip.find(params[:id]).latlngs.last(number)
  end

  def create
    trip= Trip.create trip_params
    if @current_user 
      user = @current_user.id
      trip = User.find(user).trips.create trip_params
    end
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
    @spotList = @client.spots(lat, long, :radius => 300, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
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
    @spotList = @client.spots(lat, long, :radius => 100, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    if @spotList.length < 3
      puts "hit 300"
      @spotList = @client.spots(lat, long, :radius => 300, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end
    if @spotList.length < 3
      puts "hit 1000"
      @spotList = @client.spots(lat, long, :radius => 1000, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end
    if @spotList.length < 3
      puts "hit 2000"
      @spotList = @client.spots(lat, long, :radius => 2000, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end 
    if @spotList.length < 3
      puts "hit 3500"
      @spotList = @client.spots(lat, long, :radius => 3500, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end  
    list = []
    if @spotList.length > 5 
      @spotList.each do |d|
        if d.rating
          if d.price_level
            list.push(d)
          end
        end
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
    @spotList = @client.spots(lat, long, :radius => 100, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    if @spotList.length < 3
      puts "hit 300"
      @spotList = @client.spots(lat, long, :radius => 300, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end
    if @spotList.length < 3
      puts "hit 1000"
      @spotList = @client.spots(lat, long, :radius => 1000, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end
    if @spotList.length < 3
      puts "hit 2000"
      @spotList = @client.spots(lat, long, :radius => 2000, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end 
    if @spotList.length < 3
      puts "hit 3500"
      @spotList = @client.spots(lat, long, :radius => 3500, :types => ['food','restaurant','meal_takeaway'], :exclude => ['cafe','grocery_or_supermarket','store'])
    end  
    list = []
    if @spotList.length > 5 
      @spotList.each do |d|
        if d.rating
          if d.price_level
            list.push(d)
          end
        end
      end
    end
    @spotList = list.sort! { |a,b| b.rating <=> a.rating }
    @gmap = ENV['GOOGLE_DIR']
    @trip = Trip.find params[:id]
    @destination = Destination.new
  end

  def triplist
    @trip = User.find(@current_user.id).trips
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
