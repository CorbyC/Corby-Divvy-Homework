defmodule Homework.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Companies.Company
  alias Homework.Transactions.Transaction

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies([])
      [%Company{}, ...]

  """
  def list_companies(_args) do
    companies = Repo.all(Company)
    totals = company_transaction_totals(Enum.map(companies, fn company -> company.id end)) # single query to transactions
    # Add calculated available_credit to each company
    # I feel like this can and possibly should be done at the resolvers layer instead?
    # I'd have verified with another dev before picking a spot. But I got it working here
    companies = Enum.reduce(companies, [], fn(company, acc) ->
      total = Enum.find(totals,fn x -> x.company_id == company.id end) || %{company_id: company.id, sum: 0}
      [Map.merge(company, %{available_credit: company.credit_line - total.sum}) | acc]
    end)
    companies
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id) do
    # I usually like to reduce code duplication by making the singleId just call the multiId call passing 1 id
    # But since the above doesn't take a list of ids and it'd pull all, I left this as a smaller pull
    company = Repo.get!(Company, id)
    totals = company_transaction_totals([id])
    total = Enum.find(totals,fn x -> x.company_id == company.id end) || %{company_id: company.id, sum: 0}
    Map.merge(company, %{available_credit: company.credit_line - total.sum})
  end

  @doc """
  Gets total transaxctions grouped by company

  ## Examples

      iex> company_transaction_totals(["9692694d","85dee313","04f4e614"]])
      [
        %{company_id: "9692694d", sum: 1050},
        %{company_id: "85dee313", sum: 726},
        %{company_id: "04f4e614", sum: 24}
      ]

  """
  def company_transaction_totals(ids) do
    query =
      from t in Transaction,
           where: t.company_id in ^ids
           # In the real world I'd validate requirements, because filtering by this isn't in the homework asks.
           # But we're talking about a credit line so filtering by credit type transactions makes sense to me
           and t.credit == true,
           group_by: t.company_id,

           select: %{:company_id => t.company_id, :sum => sum(t.amount)}
    Repo.all(query)
  end

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    result = %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()

    case result do
      {:ok, _} ->
        {:ok, %Company{} = company} = result
        {:ok, Map.merge(company, %{available_credit: company.credit_line})} # can't be transactions yet if first created
      {:error, %{ errors: errors }} ->
        result
    end
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    result = company
    |> Company.changeset(attrs)
    |> Repo.update()

    case result do
      {:ok, _} ->
        {:ok, %Company{} = updatedCompany} = result
        {:ok, get_company!(updatedCompany.id)} # get again to get dynamic availableCredit. There's probably a better way to do this
      {:error, %{ errors: errors }} ->
        result
    end
  end

  @doc """
  Deletes a company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end
end
