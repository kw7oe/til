defmodule TilWeb.SearchController do
  use TilWeb, :controller

  def create(conn, params) do
    IO.inspect(params)
    render(conn, "show.html")
  end
end
