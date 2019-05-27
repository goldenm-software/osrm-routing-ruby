# osrm-routing

osrm-routing is a OSRM Project routing wrapper for Ruby language

## Installation

Use the package manager [bundler](https://bundler.io/) to install osrm-routing.

```bash
gem install osrm-routing
```
OR
```ruby
gem 'osrm-routing'
```
and execute a `bundle install`

## Usage

```ruby
require 'osrm-routing'

# Address: Farmacias Arrocha, Calle 50, San Francisco, Panama City, Panama
origin = {
  latitude: 8.991968,
  longitude: -79.507402
}

# => Waypoints order
# Addess for 0: Multiplaza Pacific Mall, Punta Pacifica, Panama City, Panama
# Addess for 1: Albrook Mall, Albrook, Panama City, Panama
# Addess for 2: Universidad Interamericana de Panama, Tumba Muerto, Panama City, Panama
waypoints = [
  {
    latitude: 8.985900,
    longitude: -79.511184
  },
  {
    latitude: 8.975006,
    longitude: -79.552672
  },
  {
    latitude: 8.983851,
    longitude: -79.530008
  }
]

debug = true

routing = OSRMRouting.new(origin, waypoints, debug)

# Execute routing optimization
routing.optimize

# Result
{
  :status => 200,
  :errors => {},
  :result => {
    :optimized_route => [0, 3, 2, 1, 0],
    :total_duration => 46.97666666666667, # In minutes
    :total_distance => 21.1039, # In kilometers
    :steps => [
      {
        :origin => 0,
        :destination => 3,
        :distance => 4739.8, # In meters
        :duration => 750.9 # In seconds
      }, {
        :origin => 3,
        :destination => 2,
        :distance => 4534.4, # In meters
        :duration => 614.8 # In seconds
      }, {
        :origin => 2,
        :destination => 1,
        :distance => 10553.9, # In meters
        :duration => 1144.6 # In seconds
      }, {
        :origin => 1,
        :destination => 0,
        :distance => 1275.8, # In meters
        :duration => 308.3 # In seconds
      }
    ]
  }
}
```

## Notes
1. Value 0 is your origin

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)