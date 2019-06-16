defmodule Til.StatisticTest do
  use Til.DataCase
  alias Til.Statistic

  @today ~D[2019-02-16]
  @yesterday ~D[2019-02-15]

  describe "should_calculate_streaks" do
    test "return false if first date is neither today or yesterday" do
      result = Statistic.should_calculate_streaks(~D[2019-02-10], @today)
      refute result
    end

    test "return true if first date is today" do
      result = Statistic.should_calculate_streaks(@today, @today)
      assert result
    end

    test "return true if first date is yesteday" do
      result = Statistic.should_calculate_streaks(@yesterday, @today)
      assert result
    end
  end

  describe "calculate_streaks" do
    test "return 0 if dates is empty" do
      result = Statistic.calculate_streaks([])
      assert 0 = result
    end

    test "return 2 if consist of only two continuous dates" do
      dates = [@yesterday, ~D[2019-02-14], ~D[2019-02-12]]
      result = Statistic.calculate_streaks(dates)
      assert 2 = result
    end

    test "return 4 if consist of only four continuous dates" do
      dates = [@yesterday, ~D[2019-02-14], ~D[2019-02-13], ~D[2019-02-12]]
      result = Statistic.calculate_streaks(dates)
      assert 4 = result
    end
  end
end
