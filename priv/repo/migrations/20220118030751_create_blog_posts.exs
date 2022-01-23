defmodule Coda.Repo.Migrations.CreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add :title, :string
      add :content, :string

      timestamps()
    end
  end
end
