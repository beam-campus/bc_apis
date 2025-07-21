# Weather API Guide

The Weather API provides functions to fetch weather data using the Open-Meteo API. This service is free and doesn't require an API key.

## Features

- Get current weather conditions
- Fetch UV index data
- Convert outdoor weather to greenhouse conditions
- Comprehensive weather data including temperature, humidity, and cloud cover

## Basic Usage

### Getting Current Weather

```elixir
alias BCApis.Weather

# Fetch current weather for London coordinates
{:ok, weather} = Weather.get_current_weather(51.5074, -0.1278, nil)

# The weather data includes:
# - temperature (°C)
# - humidity (%)
# - pressure (hPa)
# - weather_condition (Clear, Clouds, Rain, etc.)
# - clouds (%)
# - wind_speed (m/s)
```

### Getting UV Index

```elixir
# Fetch UV index for a location
{:ok, uv_data} = Weather.get_uv_index(51.5074, -0.1278, nil)
# Returns: %{"value" => uv_value}
```

### Converting to Greenhouse Conditions

The API can estimate greenhouse conditions based on outdoor weather:

```elixir
# Get outdoor weather and convert to greenhouse conditions
{:ok, weather} = Weather.get_current_weather(lat, lon, nil)
greenhouse_conditions = Weather.weather_to_greenhouse_conditions(weather)

# Returns:
# %{
#   temperature: float(),  # Adjusted for greenhouse effect
#   humidity: float(),    # Adjusted for enclosed space
#   light: float()       # Adjusted for glass/plastic filtering
# }
```

## Weather Conditions

The API maps weather codes to these conditions:
- Clear
- Clouds
- Fog
- Drizzle
- Rain
- Snow
- Thunderstorm

## Response Format

The weather data includes:

```elixir
%{
  temperature: float(),      # Temperature in Celsius
  humidity: float(),        # Relative humidity percentage
  pressure: float(),        # Atmospheric pressure in hPa
  weather_condition: String.t(), # Weather condition string
  clouds: integer(),        # Cloud cover percentage
  wind_speed: float(),      # Wind speed in m/s
  city: String.t(),        # City name (if available)
  country: String.t()      # Country name (if available)
}
```

## Greenhouse Calculations

The API adjusts outdoor conditions for greenhouse environments:

1. Temperature:
   - Cold weather (< 0°C): +8°C
   - Cool weather (< 15°C): +5°C
   - Mild weather (< 25°C): +3°C
   - Warm weather: +1°C

2. Humidity:
   - Dry air (< 30%): +25%
   - Moderate (< 60%): +15%
   - Humid: +10%

3. Light:
   - Adjusted based on weather conditions and cloud cover
   - Accounts for greenhouse material transmission (typically 65%)
