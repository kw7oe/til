defmodule Til.Tasks.UpdatePostDocumentsTaskTest do
  use Til.DataCase

  alias Til.Tasks.UpdatePostDocumentsTask
  alias Til.Repo

  import Ecto.Query

  describe "run/0" do
    test "insert posts data into post documents" do
      insert(:post, title: "Post 1")
      insert(:post, title: "Post 2")
      post3 = insert(:post, title: "Post 3")
      post4 = insert(:post, title: "Post 4")
      post5 = insert(:post, title: "Post 5")
      ids = [post3.id, post4.id, post5.id]

      query =
        from q in "post_documents",
          where: q.post_id in ^ids,
          select: q.document

      Repo.delete_all(query)

      {:ok, %{num_rows: 3}} = UpdatePostDocumentsTask.run()
    end
  end
end
