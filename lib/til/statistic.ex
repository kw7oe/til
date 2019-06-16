defmodule Til.Statistic do
  alias Til.Accounts.User
  alias Til.Posts.Post

  def writing_streaks(%User{} = user) do
    dates =
      Post.submitted_by(user.id)
      |> Post.group_by_date()
      |> Til.Repo.all()
      |> List.flatten()
      # TODO: Should reverse at DB level
      |> Enum.reverse()

    # TODO: Refatoring needed
    case dates do
      [] ->
        0

      dates ->
        [first_date | _] = dates
        today = Timex.now() |> Timex.beginning_of_day() |> Timex.to_naive_datetime()
        first_date = NaiveDateTime.truncate(first_date, :second)

        if should_calculate_streaks(first_date, today) do
          calculate_streaks(dates)
        else
          0
        end
    end
  end

  def should_calculate_streaks(today, today), do: true

  def should_calculate_streaks(first_date, today) do
    yesterday = Timex.shift(today, days: -1)
    first_date == yesterday
  end

  def calculate_streaks([]), do: 0

  def calculate_streaks(dates) do
    calculate_streaks(dates, 1)
  end

  def calculate_streaks([_ | []], acc), do: acc

  def calculate_streaks([date1, date2 | tail], acc) do
    if Timex.diff(date1, date2, :days) == 1 do
      calculate_streaks([date2 | tail], acc + 1)
    else
      acc
    end
  end
end
