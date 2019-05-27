class OSRMRouting
  require 'net/http'
  require 'uri'
  require 'json'

  attr_accessor :origin, :waypoints, :debug
  @origin = {}
  @waypoints = []
  @debug = false

  def initialize(origin = {}, waypoints = [], debug = false)
    self.origin = origin
    self.waypoints = waypoints
    self.debug = debug
  end

  def optimize
    response = {
      status: 200,
      errors: {},
      result: nil
    }

    if self.origin.class != Hash
      response[:status] = 400
      response[:errors][:origin] = 'Invalid format'
    end

    if self.origin.keys.length == 0
      if response[:status] == 200
        response[:status] = 400
      end

      response[:errors][:origin] = 'Required parameter'
    end

    points = [
      [
        origin[:longitude],
        origin[:latitude]
      ]
    ]

    if self.waypoints.class != Array
      if response[:status] == 200
        response[:status] = 400
      end

      response[:errors][:waypoints] = 'Invalid format'
    end

    if self.waypoints.length == 0
      if response[:status] == 200
        response[:status] = 400
      end

      response[:errors][:waypoints] = 'Required parameter'
    end

    self.waypoints.each do |waypoint|
      if waypoint.class != Hash
        if response[:status] == 200
          response[:status] = 400
        end

        response[:errors][:waypoints] = 'Invalid format'
      end

      if waypoint.keys.length == 0
        if response[:status] == 200
          response[:status] = 400
        end

        response[:errors][:waypoints] = 'Invalid format'
      end

      if response[:status] != 200
        break
      end

      points.push([
        waypoint[:longitude],
        waypoint[:latitude]
      ])
    end

    route = "https://router.project-osrm.org/trip/v1/driving/#{points.map{ |point| point.join(",")}.join(";")}?roundtrip=true"

    if self.debug
      puts "=============================== Debug control logger ==============================="
      puts "Query route: #{route}"
      puts "===================================================================================="
    end

    uri = URI.parse(route)
    osrm = Net::HTTP.get_response(uri)

    response[:status] = osrm.code.to_i

    if response[:status] != 200
      response[:errors][:request] = "HTTP Error"
      response[:result] = JSON.parse(osrm.body)
    else
      final_route = []

      osrm = JSON.parse(osrm.body, :symbolize_names => true)
      
      osrm[:waypoints].each do |waypoint|
        final_route.push(waypoint[:waypoint_index])
      end

      final_route.push(0)

      steps = []

      osrm[:trips][0][:legs].each.with_index do |leg, i|
        if i == (osrm[:trips][0][:legs].length - 1)
          steps.push({
            origin: final_route[i],
            destination: final_route[0],
            distance: leg[:distance],
            duration: leg[:duration]
          })
        else
          steps.push({
            origin: final_route[i],
            destination: final_route[i + 1],
            distance: leg[:distance],
            duration: leg[:duration]
          })
        end
      end


      response[:result] = {
        optimized_route: final_route,
        total_duration: osrm[:trips][0][:duration] / 60.0,
        total_distance: osrm[:trips][0][:distance] / 1000.0,
        steps: steps
      }
    end

    return response
  end
end