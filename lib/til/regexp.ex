defmodule Til.Regexp do
  def http, do: ~r/^https?:\/\//
  def http_message, do: "must include http(s)://"
end
