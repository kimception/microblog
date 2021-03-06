defmodule Microblog.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Microblog.Repo

  alias Microblog.Accounts.User


  def is_admin?(nil), do: false
  def is_admin?(user) do
    user.is_admin?
  end
  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
    |> Repo.preload(:following)
    |> Repo.preload(:followers)
    |> Repo.preload(:likes)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
      Repo.get!(User, id)
      |> Repo.preload(:following)
      |> Repo.preload(:followers)
      |> Repo.preload(:likes)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
    |> Repo.preload(:following)
    |> Repo.preload(:followers)
    |> Repo.preload(:likes)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end


  alias Microblog.Accounts.Relationship


  # Referenced this blog post https://www.railstutorial.org/book/following_users for query help!
  def get_user_feed(%User{} = user) do
      following_ids = Repo.all(from r in Relationship, select: r.receiver_id, where: r.actor_id == ^user.id)
      Repo.all(from p in Microblog.Messages.Post, where: p.user_id in ^following_ids or p.user_id == ^user.id, order_by: [desc: :updated_at])
      |> Repo.preload(:user)
      |> Repo.preload(:likes)
  end

  @doc """
  Returns the list of relationships.

  ## Examples

      iex> list_relationships()
      [%Relationship{}, ...]

  """
  def list_relationships do
    Repo.all(Relationship)
    |> Repo.preload(:actor)
    |> Repo.preload(:receiver)
  end

  @doc """
  Gets a single relationship.

  Raises `Ecto.NoResultsError` if the Relationship does not exist.

  ## Examples

      iex> get_relationship!(123)
      %Relationship{}

      iex> get_relationship!(456)
      ** (Ecto.NoResultsError)

  """
  def get_relationship!(id) do
      Repo.get!(Relationship, id)
      |> Repo.preload(:actor)
      |> Repo.preload(:receiver)
  end

  def get_relationship(actor_id, receiver_id) do
      Repo.get_by(Relationship, actor_id: actor_id, receiver_id: receiver_id)
      |> Repo.preload(:actor)
      |> Repo.preload(:receiver)
  end

  def get_followers(user_id) do
    #   Repo.get_by(Relationship, receiver_id: user_id)
      Repo.all(from r in Relationship, select: r.actor_id, where: r.receiver_id == ^user_id)
    #   |> Enum.map(fn r -> r.actor_id end)
  end

  def get_following(user_id) do
      Repo.get_by(Relationship, actor_id: user_id)
      |> Repo.preload(:actor)
      |> Repo.preload(:receiver)
  end

  def is_following?(actor_id, receiver_id) do
      if Repo.get_by(Relationship, actor_id: actor_id, receiver_id: receiver_id) do
          true
      else
          false
      end
  end
  @doc """
  Creates a relationship.

  ## Examples

      iex> create_relationship(%{field: value})
      {:ok, %Relationship{}}

      iex> create_relationship(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_relationship(attrs \\ %{}) do
    %Relationship{}
    |> Relationship.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a relationship.

  ## Examples

      iex> update_relationship(relationship, %{field: new_value})
      {:ok, %Relationship{}}

      iex> update_relationship(relationship, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_relationship(%Relationship{} = relationship, attrs) do
    relationship
    |> Relationship.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Relationship.

  ## Examples

      iex> delete_relationship(relationship)
      {:ok, %Relationship{}}

      iex> delete_relationship(relationship)
      {:error, %Ecto.Changeset{}}

  """
  def delete_relationship(%Relationship{} = relationship) do
    Repo.delete(relationship)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking relationship changes.

  ## Examples

      iex> change_relationship(relationship)
      %Ecto.Changeset{source: %Relationship{}}

  """
  def change_relationship(%Relationship{} = relationship) do
    Relationship.changeset(relationship, %{})
  end
end
