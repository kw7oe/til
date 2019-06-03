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
  datetime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

  [
    title: "title-#{index}",
    content: content,
    user_id: user.id,
    inserted_at: datetime,
    updated_at: datetime
  ]
end

posts =
  1..10000
  |> Enum.map(post_attrs)

Til.Repo.insert_all(Posts.Post, posts)
