# MZ: I don't have any comments that speak to fundamental design issues or anything like that... to me, this code looks great.
# The user input could be sanitized a bit but that sort of stuff is trivial. 
# I think it's interesting how we both zeroed in on the pattern of "var_name = getter_of_var_name()"

require 'rest-client'
require 'json'
require 'addressable/uri'
require 'nokogiri'

# MZ: Anything finder! 
class IceCreamFinder
  def find
    start_address = get_starting_address
    start_coordinates = get_coordinates_for_address(start_address)
    keyword = get_keyword
    nearby_places = get_nearby_places(start_coordinates, keyword)
    display_places(nearby_places)
    selected_place = nearby_places[get_selection]
    end_coordinates = get_coordinates_for_place(selected_place)
    directions = get_directions(start_coordinates, end_coordinates)
    print_directions(directions)
  end

  def get_starting_address
    puts "Please enter a starting address: "
    print ">> "
    gets.chomp.downcase
  end

  def get_keyword
    print "What are you in the mood for? "
    gets.chomp.downcase
  end

  def get_coordinates_for_address(address)
    location_params = {
      :address => "#{address}",
      :sensor => "false"
    }

    location_url = Addressable::URI.new(
      scheme: "http",
      host: "maps.googleapis.com",
      path: "maps/api/geocode/json",
      query_values: location_params
    ).to_s

    location_response = JSON.parse(RestClient.get(location_url))
    coordinates = location_response['results'][0]['geometry']['location']
    coordinates.values.join(',')
  end

  def get_nearby_places(location, keyword)
    places_params = {
      key: "AIzaSyAJauWRcvlEcWMtLqfuEd4P1iVNLWxSQBM",
      location: "#{location}",
      radius: "1000",
      sensor: "false",
      keyword: "#{keyword}"
    }

    places_url = Addressable::URI.new(
      scheme: "https",
      host: "maps.googleapis.com",
      path: "maps/api/place/nearbysearch/json",
      query_values: places_params
    ).to_s

    places_response = JSON.parse(RestClient.get(places_url))
    places_response['results'].take(5)
  end

  def display_places(places)
    places.each_with_index do |place, i|
      puts "#{i + 1}. #{place['name']}"
      puts place['vicinity']
      puts "Rating: #{place['rating']} \n\n"
    end
  end

  def get_selection
    print "Choose one (by number) to get walking directions: "
    gets.chomp.to_i - 1
  end

  def get_coordinates_for_place(place)
    place['geometry']['location'].values.join(',')
  end

  def get_directions(from, to)

    directions_params = {
      origin: "#{from}",
      destination: "#{to}",
      sensor: "false",
      mode: "walking"
    }

    directions_url = Addressable::URI.new(
      scheme: "https",
      host: "maps.googleapis.com",
      path: "maps/api/directions/json",
      query_values: directions_params
    ).to_s

    JSON.parse(RestClient.get(directions_url))['routes'][0]['legs']
  end

  def parse_directions(directions)

    steps = directions[0]["steps"].map do |step|
      instructions = Nokogiri::HTML(step["html_instructions"])
      instructions = instructions.text

      {
        distance: step["distance"]["text"],
        instructions: instructions
      }
    end
  end

  def print_directions(directions)
    total_distance = directions[0]["distance"]["text"]
    total_time = directions[0]["duration"]["text"]
    steps = parse_directions(directions)

    puts "Walking Directions"
    puts "Distance: #{total_distance}   Time: #{total_time}"
    steps.each_with_index do |step, i|
      puts "#{i + 1}. #{step[:instructions]} (#{step[:distance]})"
    end
  end
end

finder = IceCreamFinder.new
finder.find

# results = places_response['results']
# # results.each do |hash|
# #   puts hash['name']
# #   puts hash['vicinity']
# #   puts hash['rating']
# #   puts
# # end

# ice_cream_place = results[0]
# icp_lat, icp_lng = ice_cream_place['geometry']['location'].values

