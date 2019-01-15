defmodule Til.RandomToken do
  @length 64

  def generate() do
    :crypto.strong_rand_bytes(@length)
    |> Base.url_encode64()
    |> binary_part(0, @length)
  end
end
