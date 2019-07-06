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

user_attrs = [
  %{username: "test12314", email: "test12314@email.com", password: "password"},
  %{username: "kw7oe", email: "choongkwern@hotmail.com", password: "password"}
]

create_user = fn attrs ->
  case Accounts.get_user_by_email(attrs.email) do
    nil ->
      {:ok, result} = Accounts.create_user(attrs)
      result

    user ->
      user
  end
end

user =
  user_attrs
  |> Enum.map(create_user)
  |> List.first()

# content = String.duplicate("Hello ", 10000)

post_attrs = fn index ->
  datetime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

  [
    title: "title-#{index}",
    content: "Hello World #{index}",
    user_id: user.id,
    inserted_at: datetime,
    updated_at: datetime
  ]
end

posts =
  1..10
  |> Enum.map(post_attrs)

Til.Repo.insert_all(Posts.Post, posts)
