# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Til.Repo.insert!(%Til.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Til.Accounts
alias Til.Posts

user_attrs = %{username: "test12314", email: "test12314@email.com", password: "password"}

user =
  case Accounts.get_user_by_email(user_attrs.email) do
    nil ->
      {:ok, result} = Accounts.create_user(user_attrs)
      result

    user ->
      user
  end

content = String.duplicate("Hello ", 10000)

post_attrs = fn index ->
  %{title: "title-#{index}", content: content}
end

posts =
  1..5000
  |> Enum.each(fn index ->
    Posts.create_post(user, post_attrs.(index))
  end)
