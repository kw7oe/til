defmodule Til.PostTest do
  use Til.DataCase
  alias Til.Posts.Post

  describe "group_by_date/1" do
    test "return date" do
      today = Timex.now()
      yesterday = Timex.shift(today, days: -1)
      _post = insert(:post, inserted_at: today)
      _yesterday_post = insert(:post, inserted_at: yesterday)
      _yesterday_post_2 = insert(:post, inserted_at: yesterday)

      [date1, date2] =
        Post.group_by_date()
        |> Repo.all()
        |> List.flatten()

      assert to_naive_datetime_and_truncate(today) == NaiveDateTime.truncate(date1, :second)
      assert to_naive_datetime_and_truncate(yesterday) == NaiveDateTime.truncate(date2, :second)
    end
  end

  defp to_naive_datetime_and_truncate(date) do
    date
    |> Timex.beginning_of_day()
    |> Timex.to_naive_datetime()
  end
end
