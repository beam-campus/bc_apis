# IP Info API Guide

The IP Info API provides functionality to get geographical and network information about IP addresses using ip-api.com. This service is free and provides detailed information about IP addresses.

## Features

- Get geographical location from IP
- Network and ISP information
- Timezone data
- Currency information
- Proxy and hosting detection

## Basic Usage

### Getting IP Information

```elixir
alias BCApis.IpInfoCache

# Refresh and get current IP information
{:ok, ip_info} = IpInfoCache.refresh()
```

## Response Format

The API returns comprehensive information about the IP address:

```elixir
%{
  "status" => "success",
  "continent" => String.t(),
  "continentCode" => String.t(),
  "country" => String.t(),
  "countryCode" => String.t(),
  "region" => String.t(),
  "regionName" => String.t(),
  "city" => String.t(),
  "district" => String.t(),
  "zip" => String.t(),
  "lat" => float(),
  "lon" => float(),
  "timezone" => String.t(),
  "offset" => integer(),
  "currency" => String.t(),
  "isp" => String.t(),
  "org" => String.t(),
  "as" => String.t(),
  "asname" => String.t(),
  "reverse" => String.t(),
  "mobile" => boolean(),
  "proxy" => boolean(),
  "hosting" => boolean(),
  "query" => String.t()
}
```

## Field Descriptions

### Location Information
- `continent`: Continent name
- `continentCode`: Two-letter continent code
- `country`: Country name
- `countryCode`: Two-letter country code
- `region`: Region/state code
- `regionName`: Region/state name
- `city`: City name
- `district`: District name (if available)
- `zip`: ZIP/Postal code

### Geographical Coordinates
- `lat`: Latitude
- `lon`: Longitude

### Time and Currency
- `timezone`: IANA timezone (e.g., "America/New_York")
- `offset`: UTC offset in seconds
- `currency`: Local currency code

### Network Information
- `isp`: Internet Service Provider name
- `org`: Organization name
- `as`: Autonomous System number and name
- `asname`: Autonomous System name
- `reverse`: Reverse DNS of the IP
- `query`: The IP address being queried

### Security Flags
- `mobile`: Whether IP is from a mobile network
- `proxy`: Whether IP is a proxy/VPN
- `hosting`: Whether IP belongs to a hosting/datacenter

## Error Handling

The API can return an error status:

```elixir
%{
  "status" => "fail",
  "message" => String.t()  # Error description
}
```

## Usage Notes

1. Rate Limiting:
   - Free tier has usage limits
   - Consider implementing your own caching

2. Privacy:
   - Be aware of privacy implications when storing IP data
   - Consider data retention policies

3. Performance:
   - The API performs live lookups
   - Consider implementing background refresh for better response times
