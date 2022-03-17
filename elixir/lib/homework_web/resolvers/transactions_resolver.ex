defmodule HomeworkWeb.Resolvers.TransactionsResolver do
  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users
  alias Homework.Companies
  alias HomeworkWeb.PaginationHelper

  @doc """
  Get a list of transcations
  """
  def transactions(_root, args, _info) do
    transactions = Transactions.list_transactions(args) |> Enum.map(&to_dollars/1)
    PaginationHelper.paginate(transactions, args)
  end

  @doc """
  Get the merchant associated with a transaction
  """
  def merchant(_root, _args, %{source: %{merchant_id: merchant_id}}) do
    {:ok, Merchants.get_merchant!(merchant_id)}
  end

  @doc """
  Get the user associated with a transaction
  """
  def user(_root, _args, %{source: %{user_id: user_id}}) do
    {:ok, Users.get_user!(user_id)}
  end

  @doc """
  Get the company associated with a transaction
  """
  def company(_root, _args, %{source: %{company_id: company_id}}) do
    {:ok, Companies.get_company!(company_id)}
  end

  @doc """
  Gets transactions with amount between min and max (inclusive)
  """
  def search_transactions(_root, args, _info) do
    %{min: min, max: max} = args
    transactions = Transactions.search_transactions(
      min |> to_cents,
      max |> to_cents)
      |> Enum.map(&to_dollars/1)
      PaginationHelper.paginate(transactions, args)
  end

  @doc """
  Create a new transaction
  """
  def create_transaction(_root, args, _info) do
    case Transactions.create_transaction(args |> to_cents) do
      {:ok, transaction} ->
        {:ok, transaction |> to_dollars}

      error ->
        {:error, "could not create transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a transaction for an id with args specified.
  """
  def update_transaction(_root, %{id: id} = args, _info) do
    transaction = Transactions.get_transaction!(id)

    case Transactions.update_transaction(transaction, args |> to_cents) do
      {:ok, transaction} ->
        {:ok, transaction |> to_dollars}

      error ->
        {:error, "could not update transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a transaction for an id
  """
  def delete_transaction(_root, %{id: id}, _info) do
    transaction = Transactions.get_transaction!(id)

    case Transactions.delete_transaction(transaction) do
      {:ok, transaction} ->
        {:ok, transaction |> to_dollars}

      error ->
        {:error, "could not update transaction: #{inspect(error)}"}
    end
  end

  @doc """
  For a transaction's amount field, converts the integer cents to it's decimal dollar equivalent
  """
  def to_dollars(%{amount: cents} = transaction) do
    %{transaction | amount: cents |> to_dollars}
  end

  @doc """
  Converts a decimal cents to it's decimal dollar equivalent
  """
  def to_dollars(%Decimal{} = cents) do
    Decimal.div(cents, 100) |> Decimal.round(2)
  end

  @doc """
  Converts a integer cents to it's decimal dollar equivalent
  """
  def to_dollars(cents) when is_integer(cents) do
    Decimal.div(cents, 100) |> Decimal.round(2)
  end


  @doc """
  For a transaction's amount field, converts the dollar amount to it's cents equivalent
  """
  def to_cents(%{amount: dollars} = transaction) do
    %{transaction | amount: dollars |> to_cents}
  end

  @doc """
  Converts the decimal dollar amount entered to it's cents integer equivalent
  """
  def to_cents(%Decimal{} = dollars) do
    Decimal.round(dollars, 2) |> Decimal.mult(100) |> Decimal.to_integer()
  end

  @doc """
  For a integer amount field, converts the dollar amount to it's cents equivalent
  """
  def to_cents(dollars) do
    dollars * 100
  end

end
