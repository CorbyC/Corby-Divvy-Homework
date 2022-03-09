defmodule HomeworkWeb.Schemas.UsersSchema do
  @moduledoc """
  Defines the graphql schema for user.
  """
  use Absinthe.Schema.Notation

  alias HomeworkWeb.Resolvers.UsersResolver

  object :user do
    field(:id, non_null(:id))
    field(:dob, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:company_id, :id)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)

    field(:company, :company) do
      resolve(&UsersResolver.company/3)
    end
  end

  object :user_queries do
    @desc "Get all Users"
    field(:users, list_of(:user)) do
      resolve(&UsersResolver.users/3)
    end

    @desc "Get User by id"
    field :get_user, :user do
      arg :id, non_null(:id)
      resolve fn %{id: id}, _ ->
        UsersResolver.get_solo_user(id)
      end
    end

    @desc "Gets users by fuzzy match on first name and last name. (case insensitive)"
    field(:search_users, list_of(:user)) do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))

      resolve(&UsersResolver.search_users/3)
    end
  end

  object :user_mutations do
    @desc "Create a new user"
    field :create_user, :user do
      arg(:dob, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:company_id, non_null(:id))

      resolve(&UsersResolver.create_user/3)
    end

    @desc "Update a new user"
    field :update_user, :user do
      arg(:id, non_null(:id))
      arg(:dob, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:company_id, non_null(:id))

      resolve(&UsersResolver.update_user/3)
    end

    @desc "delete an existing user"
    field :delete_user, :user do
      arg(:id, non_null(:id))

      resolve(&UsersResolver.delete_user/3)
    end
  end
end
