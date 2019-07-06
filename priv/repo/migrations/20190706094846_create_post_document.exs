defmodule Til.Repo.Migrations.CreatePostDocument do
  use Ecto.Migration

  def up do
    create table(:post_documents) do
      add(:document, :tsvector)
      add(:post_id, references(:posts, on_delete: :delete_all))
    end

    create(index(:post_documents, [:document], using: :gin))

    execute("""
      CREATE OR REPLACE FUNCTION update_post_document()
      RETURNS TRIGGER LANGUAGE plpgsql
      AS $$
      BEGIN
      IF (TG_OP = 'INSERT') THEN
        INSERT INTO post_documents VALUES(DEFAULT, to_tsvector(NEW.title) || ' ' || to_tsvector(NEW.content), NEW.id);
        RETURN NULL;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE post_documents SET document = to_tsvector(NEW.title) || ' ' || to_tsvector(NEW.content) WHERE post_id =  NEW.id;
        RETURN NULL;
      END IF;
      END $$
    """)

    execute("""
    CREATE TRIGGER update_post_document
    AFTER INSERT OR UPDATE
    ON posts
    FOR EACH ROW
    EXECUTE PROCEDURE update_post_document();
    """)
  end

  def down do
    drop_if_exists(table(:post_documents))

    execute("DROP FUNCTION IF EXISTS update_post_document()")
    execute("DROP TRIGGER IF EXISTS update_post_document ON posts")
  end
end
