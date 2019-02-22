defmodule Til.RandomToken do
  def generate(len \\ 64) do
    :crypto.strong_rand_bytes(len)
    |> Base.url_encode64()
    |> binary_part(0, len)
  end
end
