defmodule Til.TwitterIntent do
  @base_url "https://twitter.com/intent/tweet"

  @doc """
  To generate Twitter Web Intent url with its title and url.
  """
  def url(title, url), do: URI.encode("#{@base_url}?text=TIL: #{title}&url=#{url}")

  # Use in test
  def base_url, do: @base_url
end
