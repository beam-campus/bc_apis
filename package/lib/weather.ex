defmodule BCApis.Weather do
  @moduledoc """
  Weather service for integrating with Open-Meteo API.

  Provides functions to fetch current weather data and correlate it with
  greenhouse environmental conditions.

  Open-Meteo is a free, open-source weather API that doesn't require an API key.
  """

  require Logger

  @base_url "https://api.open-meteo.com/v1"

  @doc """
  Fetches current weather data for a given location.

  ## Parameters
  - `lat`: Latitude (float)
  - `lon`: Longitude (float)
  - `api_key`: Not used (Open-Meteo is free and doesn't require API key)

  ## Returns
  - `{:ok, weather_data}` on success
  - `{:error, reason}` on failure
  """
  @spec get_current_weather(float(), float(), String.t()) :: {:ok, map()} | {:error, term()}
  def get_current_weather(lat, lon, _api_key) do
    url = "#{@base_url}/forecast"

    params = %{
      latitude: lat,
      longitude: lon,
      current: "temperature_2m,relative_humidity_2m,weather_code,cloud_cover,wind_speed_10m",
      timezone: "auto"
    }

    query_string = URI.encode_query(params)
    full_url = "#{url}?#{query_string}"

    Logger.info("Weather: Fetching weather data for lat=#{lat}, lon=#{lon}")

    case Finch.build(:get, full_url) |> Finch.request(GreenhouseTycoon.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            Logger.info("Weather: Successfully fetched weather data")
            {:ok, normalize_weather_data(data)}

          {:error, reason} ->
            Logger.error("Weather: Failed to parse JSON response: #{inspect(reason)}")
            {:error, {:json_parse_error, reason}}
        end

      {:ok, %Finch.Response{status: status, body: body}} ->
        Logger.error("Weather: API request failed with status #{status}: #{body}")
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        Logger.error("Weather: HTTP request failed: #{inspect(reason)}")
        {:error, {:http_error, reason}}
    end
  end

  @doc """
  Fetches UV index data for a given location.

  ## Parameters
  - `lat`: Latitude (float)
  - `lon`: Longitude (float)
  - `api_key`: Not used (Open-Meteo is free and doesn't require API key)

  ## Returns
  - `{:ok, uv_data}` on success
  - `{:error, reason}` on failure
  """
  @spec get_uv_index(float(), float(), String.t()) :: {:ok, map()} | {:error, term()}
  def get_uv_index(lat, lon, _api_key) do
    url = "#{@base_url}/forecast"

    params = %{
      latitude: lat,
      longitude: lon,
      current: "uv_index",
      timezone: "auto"
    }

    query_string = URI.encode_query(params)
    full_url = "#{url}?#{query_string}"

    Logger.info("Weather: Fetching UV index for lat=#{lat}, lon=#{lon}")

    case Finch.build(:get, full_url) |> Finch.request(GreenhouseTycoon.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            Logger.info("Weather: Successfully fetched UV index data")
            uv_value = get_in(data, ["current", "uv_index"]) || 0
            {:ok, %{"value" => uv_value}}

          {:error, reason} ->
            Logger.error("Weather: Failed to parse UV JSON response: #{inspect(reason)}")
            {:error, {:json_parse_error, reason}}
        end

      {:ok, %Finch.Response{status: status, body: body}} ->
        Logger.error("Weather: UV API request failed with status #{status}: #{body}")
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        Logger.error("Weather: UV HTTP request failed: #{inspect(reason)}")
        {:error, {:http_error, reason}}
    end
  end

  @doc """
  Converts outdoor weather conditions to estimated greenhouse conditions.

  Greenhouses typically have:
  - Higher temperature (due to greenhouse effect)
  - Higher humidity (controlled environment)
  - Reduced light (filtered through glass/plastic)
  """
  @spec weather_to_greenhouse_conditions(map()) :: map()
  def weather_to_greenhouse_conditions(weather_data) do
    outdoor_temp = weather_data.temperature
    outdoor_humidity = weather_data.humidity

    # Estimate greenhouse conditions based on outdoor weather
    greenhouse_temp = outdoor_temp + greenhouse_temperature_offset(outdoor_temp)

    greenhouse_humidity =
      min(outdoor_humidity + greenhouse_humidity_offset(outdoor_humidity), 100)

    greenhouse_light = estimate_greenhouse_light(weather_data)

    %{
      temperature: Float.round(greenhouse_temp, 1),
      humidity: Float.round(greenhouse_humidity, 1),
      light: Float.round(greenhouse_light, 1)
    }
  end

  # Private functions

  defp normalize_weather_data(raw_data) do
    current = get_in(raw_data, ["current"]) || %{}

    %{
      temperature: get_in(current, ["temperature_2m"]) || 0.0,
      humidity: get_in(current, ["relative_humidity_2m"]) || 0.0,
      # Open-Meteo doesn't provide pressure in current endpoint
      pressure: 1013.25,
      weather_condition: weather_code_to_condition(get_in(current, ["weather_code"]) || 0),
      clouds: get_in(current, ["cloud_cover"]) || 0,
      wind_speed: get_in(current, ["wind_speed_10m"]) || 0.0,
      # Open-Meteo doesn't provide city name in weather response
      city: "Unknown",
      # Open-Meteo doesn't provide country in weather response
      country: "Unknown"
    }
  end

  defp weather_code_to_condition(0), do: "Clear"
  defp weather_code_to_condition(1), do: "Clear"
  defp weather_code_to_condition(2), do: "Clouds"
  defp weather_code_to_condition(3), do: "Clouds"
  defp weather_code_to_condition(45), do: "Fog"
  defp weather_code_to_condition(48), do: "Fog"
  defp weather_code_to_condition(51), do: "Drizzle"
  defp weather_code_to_condition(53), do: "Drizzle"
  defp weather_code_to_condition(55), do: "Drizzle"
  defp weather_code_to_condition(56), do: "Drizzle"
  defp weather_code_to_condition(57), do: "Drizzle"
  defp weather_code_to_condition(61), do: "Rain"
  defp weather_code_to_condition(63), do: "Rain"
  defp weather_code_to_condition(65), do: "Rain"
  defp weather_code_to_condition(66), do: "Rain"
  defp weather_code_to_condition(67), do: "Rain"
  defp weather_code_to_condition(71), do: "Snow"
  defp weather_code_to_condition(73), do: "Snow"
  defp weather_code_to_condition(75), do: "Snow"
  defp weather_code_to_condition(77), do: "Snow"
  defp weather_code_to_condition(80), do: "Rain"
  defp weather_code_to_condition(81), do: "Rain"
  defp weather_code_to_condition(82), do: "Rain"
  defp weather_code_to_condition(85), do: "Snow"
  defp weather_code_to_condition(86), do: "Snow"
  defp weather_code_to_condition(95), do: "Thunderstorm"
  defp weather_code_to_condition(96), do: "Thunderstorm"
  defp weather_code_to_condition(99), do: "Thunderstorm"
  defp weather_code_to_condition(_), do: "Unknown"

  defp greenhouse_temperature_offset(outdoor_temp) do
    cond do
      # Cold weather: significant greenhouse effect
      outdoor_temp < 0 -> 8.0
      # Cool weather: moderate greenhouse effect
      outdoor_temp < 15 -> 5.0
      # Mild weather: small greenhouse effect
      outdoor_temp < 25 -> 3.0
      # Warm weather: minimal greenhouse effect
      true -> 1.0
    end
  end

  defp greenhouse_humidity_offset(outdoor_humidity) do
    cond do
      # Dry air: greenhouse adds moisture
      outdoor_humidity < 30 -> 25.0
      # Moderate humidity: some increase
      outdoor_humidity < 60 -> 15.0
      # Already humid: small increase
      true -> 10.0
    end
  end

  defp map_condition_to_light("Clear"), do: 85.0
  defp map_condition_to_light("Clouds"), do: 60.0
  defp map_condition_to_light("Rain"), do: 40.0
  defp map_condition_to_light("Drizzle"), do: 45.0
  defp map_condition_to_light("Thunderstorm"), do: 25.0
  defp map_condition_to_light("Snow"), do: 35.0
  defp map_condition_to_light("Mist"), do: 50.0
  defp map_condition_to_light("Fog"), do: 30.0
  defp map_condition_to_light(_), do: 55.0

  defp estimate_greenhouse_light(weather_data) do
    cloud_cover = weather_data.clouds

    base_light =
      map_condition_to_light(weather_data.weather_condition)

    # Adjust for cloud cover and greenhouse light transmission (typically 60-70%)
    cloud_factor = 1.0 - cloud_cover / 100.0 * 0.6
    greenhouse_transmission = 0.65

    base_light * cloud_factor * greenhouse_transmission
  end
end
