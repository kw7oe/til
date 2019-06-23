defmodule TilWeb.StatisticController do
  use TilWeb, :controller

  alias Til.Statistic
  alias Til.Posts

  plug :authenticate_user

  def show(conn, _) do
    current_user = conn.assigns.current_user
    total_post_count = Posts.count_for(current_user.id)
    total_tag_count = Posts.tag_count_for(current_user.id)
    writing_streaks = Statistic.writing_streaks(current_user)

    render(conn, "show.html",
      total_post_count: total_post_count,
      writing_streaks: writing_streaks,
      total_tag_count: total_tag_count,
      layout: {TilWeb.LayoutView, "dashboard.html"}
    )
  end
end
