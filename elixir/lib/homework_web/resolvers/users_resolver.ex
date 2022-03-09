defmodule HomeworkWeb.Resolvers.UsersResolver do
  alias Homework.Users
  alias Homework.Companies

  @doc """
  Get a list of users
  """
  def users(_root, args, _info) do
    {:ok, Users.list_users(args)}
  end

  @doc """
  Get a single user
  """
  def get_solo_user(id) do
    {:ok, Users.get_user!(id)}
  end

  @doc """
   Gets users by fuzzy match on first name and last name. (case insensitive)
   """
  def search_users(_root, %{first_name: first, last_name: last}, _info) do
    {:ok, Users.search_users(first, last)}
  end

  @doc """
  Get the company associated with a user
  """
  def company(_root, _args, %{source: %{company_id: company_id}}) do
    {:ok, Companies.get_company!(company_id)}
  end

  @doc """
  Creates a user
  """
  def create_user(_root, args, _info) do
    case Users.create_user(args) do
      {:ok, user} ->
        {:ok, user}

      error ->
        {:error, "could not create user: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a user for an id with args specified.
  """
  def update_user(_root, %{id: id} = args, _info) do
    user = Users.get_user!(id)

    case Users.update_user(user, args) do
      {:ok, user} ->
        {:ok, user}

      error ->
        {:error, "could not update user: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a user for an id
  """
  def delete_user(_root, %{id: id}, _info) do
    user = Users.get_user!(id)

    case Users.delete_user(user) do
      {:ok, user} ->
        {:ok, user}

      error ->
        {:error, "could not update user: #{inspect(error)}"}
    end
  end
end
