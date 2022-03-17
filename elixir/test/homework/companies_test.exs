defmodule Homework.CompaniesTest do
  use Homework.DataCase
  use Ecto.Schema

  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users
  alias Homework.Companies
  alias HomeworkWeb.Resolvers.CompaniesResolver

  describe "companies" do
    alias Homework.Companies.Company

    # Pre-seed tests
    setup do
      {:ok, merchant1} =
        Merchants.create_merchant(%{
          description: "some description",
          name: "some name"
        })

      {:ok, company1} =
        Companies.create_company(%{
          name: "setup company 1",
          credit_line: 45000,
        })

      {:ok, company2} =
        Companies.create_company(%{
          name: "setup company 2",
          credit_line: 77000,
        })

      {:ok, user1} =
        Users.create_user(%{
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name",
          company_id: company1.id
        })

      {:ok, transaction1} =
        Transactions.create_transaction(%{
          amount: Enum.random(0..25000),
          credit: true,
          debit: false,
          description: "some description",
          merchant_id: merchant1.id,
          user_id: user1.id,
          company_id: company1.id
      })

      {:ok, transaction2} =
        Transactions.create_transaction(%{
          amount: Enum.random(0..20000),
          credit: true,
          debit: false,
          description: "some description",
          merchant_id: merchant1.id,
          user_id: user1.id,
          company_id: company1.id
      })

      {:ok, transaction3} =
        Transactions.create_transaction(%{
          amount: Enum.random(0..120000),
          credit: false, # to make sure it only honors credit transactions when calculating available credit
          debit: true,
          description: "some description",
          merchant_id: merchant1.id,
          user_id: user1.id,
          company_id: company1.id
      })

      {:ok,
       %{
         merchant1: merchant1,
         user1: user1,
         company1: company1,
         company2: company2,
         transaction1: transaction1,
         transaction2: transaction2,
         transaction3: transaction3,
       }}
    end

    @valid_attrs %{name: "some name", credit_line: 9000}
    @update_attrs %{
      name: "some updated name",
      credit_line: 9001
    }
    @invalid_attrs %{name: nil, credit_line: nil}

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Companies.create_company()

      company
    end

    test "list_companies/1 returns all companies" do
      company_fixture()
      assert Enum.count(Companies.list_companies([])) == 3
    end

    test "list_companies!/1 returns calculated available_credit for company with given id", %{company1: company1, transaction1: transaction1, transaction2: transaction2} do
      companies = Companies.list_companies([])
      company = Enum.find(companies,fn c -> c.id == company1.id end)
      assert company.available_credit == (company1.credit_line - transaction1.amount - transaction2.amount)
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Companies.get_company!(company.id) == company
    end

    test "get_company!/1 returns calculated available_credit for company with given id", %{company1: company1, transaction1: transaction1, transaction2: transaction2} do
      assert Companies.get_company!(company1.id).available_credit == (company1.credit_line - transaction1.amount - transaction2.amount)
    end

    test "create_company/1 with valid data creates a company" do
      assert {:ok, %Company{} = company} = Companies.create_company(@valid_attrs)
      assert company.name == "some name"
      assert company.credit_line == 9000
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Companies.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      assert {:ok, %Company{} = company} = Companies.update_company(company, @update_attrs)
      assert company.name == "some updated name"
      assert company.credit_line == 9001
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Companies.update_company(company, @invalid_attrs)
      assert company == Companies.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Companies.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Companies.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Companies.change_company(company)
    end

    # resolvers tests
    test "resolver get companies/3" do
      {:ok, companies } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companies) == 2
    end

    test "resolver get_solo_company/1", %{company1: company1} do
      {:ok, company } = CompaniesResolver.get_solo_company(company1.id)
      assert company.id == company1.id
      assert company.name == company1.name
    end

    test "resolver get fake solo company" do
      try do
        CompaniesResolver.get_solo_company(Ecto.UUID.generate())
      rescue
        e -> assert String.contains?(e.message, "expected at least one result but got none in query")
      end
    end

    test "resolver create_company/3" do
      {:ok, companiesBefore } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesBefore) == 2
      companyName = "New test company"
      companyCreditLine = 55555
      {:ok, company } = CompaniesResolver.create_company(nil, %{name: companyName, credit_line: companyCreditLine}, nil)
      assert company.name == companyName
      assert company.credit_line == companyCreditLine
      {:ok, companiesAfter } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesAfter) == 3
    end

    test "resolver udpate_company/3", %{company1: company1} do
      {:ok, companiesBefore } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesBefore) == 2
      {:ok, company } = CompaniesResolver.get_solo_company(company1.id)
      assert company.id == company1.id
      assert company.name == company1.name
      assert company.credit_line == company1.credit_line

      companyName = "New update name"
      companyCreditLine = 55555
      {:ok, company } = CompaniesResolver.update_company(nil, %{id: company1.id, name: companyName, credit_line: companyCreditLine}, nil)
      assert company.id == company1.id
      assert company.name == companyName
      assert company.credit_line == companyCreditLine
      {:ok, companiesAfter } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesAfter) == 2
    end

    test "resolver update fake company" do
      try do
        CompaniesResolver.update_company(nil, %{id: Ecto.UUID.generate(), name: "Wont matter", credit_line: 1}, nil)
      rescue
        e -> assert String.contains?(e.message, "expected at least one result but got none in query")
      end
    end

    test "resolver delete_company/3 with no transactions", %{company2: company2} do
      {:ok, companiesBefore } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesBefore) == 2
      {:ok, _ } = CompaniesResolver.delete_company(nil, %{id: company2.id}, nil)
      {:ok, companiesAfter } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesAfter) == 1
    end

    test "resolver cannot delete company with transactions", %{company1: company1} do
      # we could make deleting companies cascade delete transactions, but for now we'll leave it as a blocking behavior
      {:ok, companiesBefore } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesBefore) == 2
      try do
        CompaniesResolver.delete_company(nil, %{id: company1.id}, nil)
      rescue
        e -> assert String.contains?(e.message, "transactions_company_id_fkey (foreign_key_constraint)")
      end
      {:ok, companiesAfter } = CompaniesResolver.companies(nil, {}, nil)
      assert Enum.count(companiesAfter) == 2
    end

  end
end
