defmodule BCApis.WeatherTest do
  use ExUnit.Case, async: true
  doctest BCApis.Weather

  alias BCApis.Weather
  import BCApis.TestHelpers

  describe "get_current_weather/3" do
    test "successfully gets weather data" do
      response = mock_weather_response()
      
      with_mock_http response, fn _mock ->
        assert {:ok, weather} = Weather.get_current_weather(51.5074, -0.1278, nil)
        assert weather.temperature == 20.5
        assert weather.humidity == 65.0
        assert weather.weather_condition == "Clear"
      end
    end

    test "handles API errors" do
      with_mock_http {:error, %{reason: "timeout"}}, fn _mock ->
        assert {:error, {:http_error, _}} = Weather.get_current_weather(51.5074, -0.1278, nil)
      end
    end

    test "handles invalid JSON response" do
      with_mock_http "invalid json", fn _mock ->
        assert {:error, {:json_parse_error, _}} = Weather.get_current_weather(51.5074, -0.1278, nil)
      end
    end
  end

  describe "get_uv_index/3" do
    test "successfully gets UV index" do
      response = %{"current" => %{"uv_index" => 5.7}}
      
      with_mock_http response, fn _mock ->
        assert {:ok, %{"value" => 5.7}} = Weather.get_uv_index(51.5074, -0.1278, nil)
      end
    end

    test "handles missing UV data" do
      response = %{"current" => %{}}
      
      with_mock_http response, fn _mock ->
        assert {:ok, %{"value" => 0}} = Weather.get_uv_index(51.5074, -0.1278, nil)
      end
    end
  end

  describe "weather_to_greenhouse_conditions/1" do
    test "converts outdoor conditions to greenhouse conditions" do
      outdoor_weather = %{
        temperature: 20.0,
        humidity: 50.0,
        weather_condition: "Clear",
        clouds: 25
      }

      greenhouse = Weather.weather_to_greenhouse_conditions(outdoor_weather)

      assert is_float(greenhouse.temperature)
      assert is_float(greenhouse.humidity)
      assert is_float(greenhouse.light)
      
      # Greenhouse should be warmer
      assert greenhouse.temperature > outdoor_weather.temperature
      # Greenhouse should be more humid
      assert greenhouse.humidity > outdoor_weather.humidity
      # Light should be adjusted for greenhouse transmission
      assert greenhouse.light > 0 and greenhouse.light <= 100
    end

    test "handles extreme conditions" do
      # Cold weather
      cold_weather = %{
        temperature: -10.0,
        humidity: 20.0,
        weather_condition: "Clear",
        clouds: 0
      }

      cold_greenhouse = Weather.weather_to_greenhouse_conditions(cold_weather)
      assert cold_greenhouse.temperature > cold_weather.temperature + 5.0

      # Hot weather
      hot_weather = %{
        temperature: 35.0,
        humidity: 80.0,
        weather_condition: "Clear",
        clouds: 0
      }

      hot_greenhouse = Weather.weather_to_greenhouse_conditions(hot_weather)
      assert hot_greenhouse.humidity <= 100.0
    end

    test "adjusts light based on weather conditions" do
      clear_weather = %{
        temperature: 20.0,
        humidity: 50.0,
        weather_condition: "Clear",
        clouds: 0
      }

      cloudy_weather = %{
        temperature: 20.0,
        humidity: 50.0,
        weather_condition: "Clouds",
        clouds: 100
      }

      clear = Weather.weather_to_greenhouse_conditions(clear_weather)
      cloudy = Weather.weather_to_greenhouse_conditions(cloudy_weather)

      assert clear.light > cloudy.light
    end
  end
end
