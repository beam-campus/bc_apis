defmodule BCApis.GeocodingTest do
  use ExUnit.Case, async: true
  doctest BCApis.Geocoding

  alias BCApis.Geocoding
  import BCApis.TestHelpers

  describe "geocode_city/3" do
    test "successfully geocodes a valid city" do
      response = mock_geocoding_response()
      
      with_mock_http response, fn _mock ->
        assert {:ok, {51.5074, -0.1278}} = Geocoding.geocode_city("London", "GB", nil)
      end
    end

    test "returns error for nonexistent city" do
      response = %{"results" => []}
      
      with_mock_http response, fn _mock ->
        assert {:error, :not_found} = Geocoding.geocode_city("NonexistentCity", "GB", nil)
      end
    end

    test "returns error for country mismatch" do
      response = %{
        "results" => [
          %{
            "latitude" => 51.5074,
            "longitude" => -0.1278,
            "country_code" => "FR",
            "name" => "London"
          }
        ]
      }
      
      with_mock_http response, fn _mock ->
        assert {:error, :country_mismatch} = Geocoding.geocode_city("London", "GB", nil)
      end
    end

    test "handles invalid response data" do
      response = %{"results" => [%{"invalid" => "data"}]}
      
      with_mock_http response, fn _mock ->
        assert {:error, :invalid_response} = Geocoding.geocode_city("London", "GB", nil)
      end
    end
  end

  describe "coordinates_to_location_string/2" do
    test "formats coordinates correctly" do
      assert "51.5074,-0.1278" = Geocoding.coordinates_to_location_string(51.5074, -0.1278)
    end
  end

  describe "get_major_cities/1" do
    test "returns cities for supported countries" do
      cities = Geocoding.get_major_cities("US")
      assert length(cities) == 10
      assert "New York" in cities
    end

    test "returns empty list for unsupported country" do
      assert [] = Geocoding.get_major_cities("XX")
    end

    test "handles case insensitive country codes" do
      assert Geocoding.get_major_cities("us") == Geocoding.get_major_cities("US")
    end
  end
end
