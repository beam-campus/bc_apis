# BEAM Campus APIs

BEAM Campus APIs (BCApis) provides a collection of freely available APIs for Elixir projects. It includes services for geocoding, weather information, country data, and IP information.

## Installing BEAM Campus APIs

### In mix.exs

Add BCApis to your list of dependencies:

```elixir
def deps do
  [
    {:bc_apis, "~> 0.1.0"},
    
    # Optional Dependencies
    {:jason, "~> 1.4"},           # If you need JSON handling
    {:phoenix_pubsub, "~> 2.1"}  # If you need PubSub functionality
  ]
end
```

### Required Runtime Dependencies

BCApis has these core dependencies:
- `uuidv7` and `elixir_uuid` for ID generation
- `telemetry` for metrics and instrumentation
- `bc_utils` for BEAM Campus utilities

### Optional Dependencies

Some features require optional dependencies:
- `jason` for JSON handling
- `phoenix_pubsub` for PubSub functionality
- `req` and `hackney` for HTTP capabilities
- `typed_struct` for type-safe structs
- `cachex` for caching

## Available APIs

| API | Free? | Purpose | Guide |
|-----|--------|---------|--------|
| Geocoding | ✅ | Convert city names to coordinates | [Guide](./geocoding.md) |
| Weather | ✅ | Get weather and UV index data | [Guide](./weather.md) |
| Countries | ✅ | Access country information | [Guide](./countries.md) |
| IP Info | ✅ | Get location from IP addresses | [Guide](./ip_info.md) |

## Quick Start Example

```elixir
# Start the Countries service (required for some features)
BCApis.Countries.start(true)

# Get coordinates for a city
{:ok, {lat, lon}} = BCApis.Geocoding.geocode_city("London", "GB", nil)

# Get current weather
{:ok, weather} = BCApis.Weather.get_current_weather(lat, lon, nil)

# Get country information
{:ok, country} = BCApis.Countries.get_country_by_country_code("GB")

# Get IP information
{:ok, ip_info} = BCApis.IpInfoCache.refresh()
```

## Configuration

Most services are provided by free APIs that don't require API keys:

### Geocoding and Weather
Provided by Open-Meteo:
- No API key required
- Free tier with generous limits
- Uses `https://geocoding-api.open-meteo.com/v1`
- Uses `https://api.open-meteo.com/v1`

### Countries Data
Provided by restcountries.com:
- No API key required
- Can work offline with local data
- Uses `https://restcountries.com/v3.1`

### IP Information
Provided by ip-api.com:
- No API key required
- Free tier with rate limits
- Uses `http://ip-api.com/json`

## Development Tools

BCApis includes several development tools:

### Code Quality
```bash
# Type checking
mix dialyzer

# Code analysis
mix credo

# Documentation
mix docs
```

### Testing
```bash
# Run tests
mix test

# Watch for changes
mix test.watch

# Check coverage
mix coveralls
```

## Common Use Cases

### 1. Getting Weather for a City
```elixir
with {:ok, {lat, lon}} <- BCApis.Geocoding.geocode_city("Paris", "FR", nil),
     {:ok, weather} <- BCApis.Weather.get_current_weather(lat, lon, nil) do
  # Process weather data
  weather.temperature
  weather.humidity
  weather.weather_condition
end
```

### 2. Finding Countries by Region
```elixir
# Start the service
BCApis.Countries.start(true)

# Get European countries with minimum area and population
countries = BCApis.Countries.countries_of_regions(
  ["Europe"],  # regions
  100_000,    # min area km²
  1_000_000   # min population
)
```

### 3. Getting Location from IP
```elixir
{:ok, info} = BCApis.IpInfoCache.refresh()

location = {
  city: info["city"],
  country: info["country"],
  timezone: info["timezone"]
}
```

## Error Handling

All APIs use consistent error tuples:

```elixir
# Success
{:ok, result} = BCApis.Geocoding.geocode_city("London", "GB", nil)

# Various errors
{:error, :not_found}           # Resource not found
{:error, :invalid_parameters}  # Bad input
{:error, {:http_error, reason}} # Network issues
{:error, reason}              # Other errors
```

## Learn More

- [Geocoding Guide](./geocoding.md)
- [Weather Guide](./weather.md)
- [Countries Guide](./countries.md)
- [IP Info Guide](./ip_info.md)

## Contributing

Issues and pull requests are welcome on GitHub at https://github.com/beam-campus/bc_apis.

## License

The package is available as open source under the terms of the MIT License.
