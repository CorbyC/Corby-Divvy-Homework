defmodule Homework.CompaniesTest do
  use Homework.DataCase

  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users
  alias Homework.Companies

  describe "companies" do
    alias Homework.Companies.Company

    # setup do
    #   {:ok, merchant1} =
    #     Merchants.create_merchant(%{
    #       description: "some description",
    #       name: "some name"
    #     })

    #   {:ok, merchant2} =
    #     Merchants.create_merchant(%{
    #       description: "some updated description",
    #       name: "some updated name"
    #     })

    #   {:ok, company1} =
    #     Companies.create_company(%{
    #       name: "some name",
    #       credit_line: 45000
    #     })

    #   {:ok, company2} =
    #     Companies.create_company(%{
    #       name: "some update name",
    #       credit_line: 77000
    #     })

    #   {:ok, user1} =
    #     Users.create_user(%{
    #       dob: "some dob",
    #       first_name: "some first_name",
    #       last_name: "some last_name",
    #       company_id: company1.id
    #     })

    #   {:ok, transaction1} =
    #     Transactions.create_transaction(%{
    #       amount: 42,
    #       credit: false,
    #       debit: true,
    #       description: "some description",
    #       merchant_id: merchant1.id,
    #       user_id: user1.id,
    #       company_id: company1.id
    #   })

    #   {:ok, transaction2} =
    #     Transactions.create_transaction(%{
    #       amount: 42,
    #       credit: false,
    #       debit: true,
    #       description: "some description",
    #       merchant_id: merchant1.id,
    #       user_id: user1.id,
    #       company_id: company1.id
    #   })

    #   {:ok,
    #    %{
    #      merchant1: merchant1,
    #      merchant2: merchant2,
    #      user1: user1,
    #      company1: company1,
    #      company2: company2,
    #      transaction1: transaction1,
    #      transaction2: transaction2,
    #    }}
    # end

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
      company = company_fixture()
      assert Companies.list_companies([]) == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Companies.get_company!(company.id) == company
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
  end
end
