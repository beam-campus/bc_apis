# Geocoding API Guide

The Geocoding API provides functions to convert city names to coordinates using the Open-Meteo Geocoding API. This service is free and doesn't require an API key.

## Features

- Convert city names to coordinates
- Validate country codes
- Access a database of major cities by country
- Convert coordinates to location strings

## Basic Usage

### Converting City Names to Coordinates

```elixir
alias BCApis.Geocoding

# Basic city lookup
{:ok, {lat, lon}} = Geocoding.geocode_city("London", "GB", nil)

# The API key parameter is not used (Open-Meteo is free)
{:ok, {lat, lon}} = Geocoding.geocode_city("Paris", "FR", nil)
```

### Error Handling

The geocoding function returns:
- `{:ok, {lat, lon}}` on success
- `{:error, :not_found}` if the city isn't found
- `{:error, :country_mismatch}` if the city is found but in wrong country
- `{:error, reason}` for other errors

```elixir
case Geocoding.geocode_city("NonexistentCity", "US", nil) do
  {:ok, {lat, lon}} ->
    # Process coordinates
  {:error, :not_found} ->
    # Handle city not found
  {:error, reason} ->
    # Handle other errors
end
```

### Getting Major Cities

The API provides a list of major cities for supported countries:

```elixir
# Get major US cities
cities = Geocoding.get_major_cities("US")
# Returns: ["New York", "Los Angeles", "Chicago", ...]

# Get major UK cities
cities = Geocoding.get_major_cities("GB")
# Returns: ["London", "Birmingham", "Manchester", ...]
```

### Converting Coordinates to Location String

```elixir
location = Geocoding.coordinates_to_location_string(51.5074, -0.1278)
# Returns: "51.5074,-0.1278"
```

## Supported Countries

The API supports major cities in these countries:
- US (United States)
- CA (Canada)
- GB (United Kingdom)
- DE (Germany)
- FR (France)
- IT (Italy)
- ES (Spain)
- NL (Netherlands)
- AU (Australia)
- JP (Japan)
- CN (China)
- BR (Brazil)
- MX (Mexico)
- IN (India)
- ZA (South Africa)

Each country provides a list of its 10 major cities.
