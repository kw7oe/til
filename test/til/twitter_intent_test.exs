defmodule Til.TwitterIntentTest do
  use ExUnit.Case, async: true

  alias Til.TwitterIntent

  describe "url/2 handle special character correctly" do
    test "can handle % and whitespace" do
      url = "https://til.com"
      result = TwitterIntent.url("N%", url)

      expected_result = "#{TwitterIntent.base_url}?text=TIL:%20N%25&url=#{url}"
      assert result == expected_result
    end

  end
end
