defmodule Til.Factory do
  use ExMachina.Ecto, repo: Til.Repo

  def user_factory do
    %Til.Accounts.User{
      username: sequence(:username, &"user-#{&1}"),
      email: sequence(:email, &"user-#{&1}@email.com"),
      password: "password",
      bio: "I am a fake account",
      website: "www.fake-user.com"
    }
  end

  def confirmed_user_factory do
    struct!(
      user_factory(),
      %{confirmed: true}
    )
  end

  def post_factory do
    %Til.Posts.Post{
      title: sequence(:title, &"title-#{&1}"),
      content: "Hello World"
    }
  end

  def tag_factory do
    %Til.Posts.Tag{
      name: sequence(:name, &"tag-#{&1}")
    }
  end
end
