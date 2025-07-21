defmodule BCApis.CountriesTest do
  use ExUnit.Case, async: false  # GenServer tests can't be async
  doctest BCApis.Countries

  alias BCApis.Countries
  import BCApis.TestHelpers

  setup do
    # Start the Countries service with mock data
    start_supervised!(Countries)
    :ok
  end

  describe "start/1" do
    test "starts with local data" do
      assert {:ok, _pid} = Countries.start(true)
    end

    test "starts with remote data" do
      with_mock_http mock_country_data(), fn _mock ->
        assert {:ok, _pid} = Countries.start(false)
      end
    end
  end

  describe "all_countries/0" do
    test "returns list of country names" do
      countries = Countries.all_countries()
      assert is_list(countries)
      assert "United Kingdom" in countries
    end
  end

  describe "random_country/0" do
    test "returns a valid country name" do
      country = Countries.random_country()
      assert is_binary(country)
      assert country in Countries.all_countries()
    end
  end

  describe "independent_countries/1" do
    test "filters by minimum population" do
      countries = Countries.independent_countries(50_000_000)
      
      refute "Iceland" in countries  # Too small population
      assert "United Kingdom" in countries  # Large enough population
    end
  end

  describe "farmable_countries/2" do
    test "filters by area and population" do
      countries = Countries.farmable_countries(100_000, 1_000_000)
      
      # Should include large, populated countries in farmable latitudes
      assert "United Kingdom" in countries
      
      # Should exclude countries outside farmable latitudes or too small
      refute "Iceland" in countries  # Too far north
      refute "Singapore" in countries  # Too small area
    end
  end

  describe "all_regions/0" do
    test "returns list of unique regions" do
      regions = Countries.all_regions()
      assert is_list(regions)
      assert "Europe" in regions
    end
  end

  describe "countries_of_regions/3" do
    test "filters countries by region, area, and population" do
      countries = Countries.countries_of_regions(
        ["Europe"],
        100_000,  # min area
        1_000_000 # min population
      )

      # Check returned data structure
      country = Enum.find(countries, &(&1.name == "United Kingdom"))
      assert country.region == "Europe"
      assert country.area >= 100_000
      assert country.population >= 1_000_000
    end

    test "handles multiple regions" do
      countries = Countries.countries_of_regions(
        ["Europe", "Asia"],
        100_000,
        1_000_000
      )

      # Should include countries from both regions
      europe_country = Enum.find(countries, &(&1.region == "Europe"))
      asia_country = Enum.find(countries, &(&1.region == "Asia"))

      assert europe_country != nil
      assert asia_country != nil
    end
  end

  describe "get_country_by_country_code/1" do
    test "finds country by two-letter code" do
      {:ok, country} = Countries.get_country_by_country_code("GB")
      assert country["name"]["common"] == "United Kingdom"
    end

    test "finds country by three-letter code" do
      {:ok, country} = Countries.get_country_by_country_code("GBR")
      assert country["name"]["common"] == "United Kingdom"
    end

    test "handles unknown country code" do
      assert {:error, "Country not found"} = Countries.get_country_by_country_code("XX")
    end
  end

  describe "cache operations" do
    test "refresh/1 updates the cache" do
      assert :ok = Countries.refresh(true)  # Local refresh
      
      with_mock_http mock_country_data(), fn _mock ->
        assert :ok = Countries.refresh(false)  # Remote refresh
      end
    end

    test "clear/0 empties the cache" do
      before_count = length(Countries.all_countries())
      assert before_count > 0

      Countries.clear()
      :timer.sleep(100)  # Allow for async operations

      after_count = length(Countries.all_countries())
      assert after_count == 0
    end
  end
end
