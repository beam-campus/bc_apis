defmodule BCApis.IpInfoTest do
  use ExUnit.Case, async: true
  doctest BCApis.IpInfoCache

  alias BCApis.IpInfoCache
  import BCApis.TestHelpers

  describe "refresh/0" do
    test "successfully fetches IP info" do
      response = mock_ip_info_response()
      
      with_mock_http response, fn _mock ->
        assert {:ok, info} = IpInfoCache.refresh()
        assert info["status"] == "success"
        assert info["country"] == "United Kingdom"
        assert info["city"] == "London"
      end
    end

    test "handles API errors" do
      with_mock_http {:error, %{reason: "timeout"}}, fn _mock ->
        assert {:error, _} = IpInfoCache.refresh()
      end
    end

    test "handles invalid response data" do
      with_mock_http %{"status" => "fail", "message" => "Invalid request"}, fn _mock ->
        assert {:error, _} = IpInfoCache.refresh()
      end
    end
  end

  describe "response validation" do
    test "validates required fields" do
      response = Map.drop(mock_ip_info_response(), ["country", "city"])
      
      with_mock_http response, fn _mock ->
        assert {:ok, info} = IpInfoCache.refresh()
        assert info["status"] == "success"
        refute Map.has_key?(info, "country")
        refute Map.has_key?(info, "city")
      end
    end

    test "handles unexpected field types" do
      response = %{
        mock_ip_info_response() |
        "latitude" => "invalid",
        "longitude" => "invalid"
      }
      
      with_mock_http response, fn _mock ->
        assert {:ok, info} = IpInfoCache.refresh()
        assert info["status"] == "success"
        assert info["lat"] == nil
        assert info["lon"] == nil
      end
    end
  end
end
