defmodule Til.RandomToken do
  def generate(len \\ 64) do
    len
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, len)
  end
end
