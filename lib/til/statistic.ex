defmodule Til.Statistic do
  alias Til.Accounts.User
  alias Til.Posts.Post

  def writing_streaks(%User{} = user) do
    Post.submitted_by(user.id)
    |> Post.group_by_date()
    |> Til.Repo.all()
    |> List.flatten()
    |> IO.inspect()
    |> Enum.map(fn date ->
      Timex.format!(date, "%d-%m-%Y", :strftime)
    end)
    |> IO.inspect()

    14
  end
end
