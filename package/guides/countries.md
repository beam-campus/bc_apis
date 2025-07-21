# Countries API Guide

The Countries API provides access to country information using data from restcountries.com. It maintains a cached list of countries and provides various query functions.

## Features

- Get list of all countries
- Query countries by region
- Filter by area and population
- Find farmable countries
- Get country details by country code
- Access to country flags and geographical data

## Basic Usage

### Starting the Service

The Countries API is a GenServer that needs to be started before use:

```elixir
alias BCApis.Countries

# Start with local data (recommended)
Countries.start(true)

# Or start with live data from restcountries.com
Countries.start(false)
```

### Basic Queries

```elixir
# Get all country names
countries = Countries.all_countries()

# Get a random country
country = Countries.random_country()

# Get a specific country by code
{:ok, country} = Countries.get_country_by_country_code("GB")
```

### Filtering Countries

```elixir
# Get independent countries with minimum population
countries = Countries.independent_countries(1_000_000)

# Get farmable countries (suitable for agriculture)
countries = Countries.farmable_countries(
  min_area = 100_000,        # minimum area in km²
  min_population = 1_000_000 # minimum population
)
```

### Regional Queries

```elixir
# Get all regions
regions = Countries.all_regions()

# Get countries in specific regions
countries = Countries.countries_of_regions(
  ["Europe", "Asia"],  # list of regions
  100_000,            # minimum area
  1_000_000           # minimum population
)
```

## Response Formats

### Country Details

```elixir
%{
  "name" => %{
    "common" => "United Kingdom",
    # other name formats...
  },
  "region" => "Europe",
  "subregion" => "Northern Europe",
  "area" => 242900.0,
  "population" => 67215293,
  "latlng" => [54.0, -2.0],
  "flags" => %{
    "svg" => "https://flagcdn.com/gb.svg",
    # other flag formats...
  }
  # other country details...
}
```

### Farmable Country Criteria

A country is considered farmable if it:
- Has minimum required area
- Has minimum required population
- Is located between 12° and 65° latitude (absolute value)
- Is independent

## Cache Management

```elixir
# Refresh the cache
Countries.refresh()

# Clear the cache
Countries.clear()
```

## Performance Considerations

- The API maintains a cache to minimize network requests
- Local mode uses embedded JSON data
- Cache refreshes are asynchronous
- Consider using local mode in production for reliability
