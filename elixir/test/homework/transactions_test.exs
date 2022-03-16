defmodule Homework.TransactionsTest do
  use Homework.DataCase

  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users
  alias Homework.Companies
  alias HomeworkWeb.Resolvers.TransactionsResolver

  describe "transactions" do
    alias Homework.Transactions.Transaction

    setup do
      {:ok, merchant1} =
        Merchants.create_merchant(%{
          description: "some description",
          name: "some name"
        })

      {:ok, merchant2} =
        Merchants.create_merchant(%{
          description: "some updated description",
          name: "some updated name"
        })

      {:ok, company1} =
        Companies.create_company(%{
          name: "some name",
          credit_line: 45000
        })

      {:ok, company2} =
        Companies.create_company(%{
          name: "some update name",
          credit_line: 77000
        })

      {:ok, user1} =
        Users.create_user(%{
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name",
          company_id: company1.id
        })

      {:ok, user2} =
        Users.create_user(%{
          dob: "some updated dob",
          first_name: "some updated first_name",
          last_name: "some updated last_name",
          company_id: company2.id
        })

      {:ok, _transaction1} =
        Transactions.create_transaction(%{
          amount: 1000,
          credit: false,
          debit: true,
          description: "pre-existing transaction",
          merchant_id: merchant1.id,
          user_id: user1.id,
          company_id: company1.id
        })

       {:ok, _transaction2} =
          Transactions.create_transaction(%{
            amount: 2000,
            credit: false,
            debit: true,
            description: "pre-existing transaction2",
            merchant_id: merchant1.id,
            user_id: user1.id,
            company_id: company1.id
        })

       {:ok, _transaction3} =
          Transactions.create_transaction(%{
            amount: 3000,
            credit: false,
            debit: true,
            description: "pre-existing transaction3",
            merchant_id: merchant1.id,
            user_id: user1.id,
            company_id: company1.id
        })


      valid_attrs = %{
        amount: 42,
        # mismatched a unit test. Changed here instead of the test because I'd think a transaction is credit OR debit but not both
        credit: false,
        debit: true,
        description: "some description",
        merchant_id: merchant1.id,
        user_id: user1.id,
        company_id: company1.id
      }

      update_attrs = %{
        amount: 43,
        credit: false,
        debit: false,
        description: "some updated description",
        merchant_id: merchant2.id,
        user_id: user2.id,
        company_id: company2.id
      }

      invalid_attrs = %{
        amount: nil,
        credit: nil,
        debit: nil,
        description: nil,
        merchant_id: nil,
        user_id: nil,
        company_id: nil
      }

      {:ok,
       %{
         valid_attrs: valid_attrs,
         update_attrs: update_attrs,
         invalid_attrs: invalid_attrs,
         merchant1: merchant1,
         merchant2: merchant2,
         user1: user1,
         user2: user2,
         company1: company1,
         company2: company2
       }}
    end

    def transaction_fixture(valid_attrs, attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(valid_attrs)
        |> Transactions.create_transaction()

      transaction
    end

    test "list_transactions/1 returns all transactions", %{valid_attrs: valid_attrs} do
      transaction_fixture(valid_attrs) # one more for funsies
      assert Enum.count(Transactions.list_transactions([])) == 4
    end

    test "get_transaction!/1 returns the transaction with given id", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "search_transactionss/2 returns the transaction with proper search", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert Transactions.search_transactions(30,50) == [transaction]
    end

    test "search_transactions/2 finds none if none match", %{valid_attrs: valid_attrs} do
      transaction_fixture(valid_attrs)
      assert Transactions.search_transactions(50,100) == []
    end

    test "search_transactions/2 boundary test", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert Transactions.search_transactions(42,500) == [transaction]
      assert Transactions.search_transactions(1,42) == [transaction]
      assert Transactions.search_transactions(42,42) == [transaction]
      assert Transactions.search_transactions(41,41) == []
      assert Transactions.search_transactions(43,43) == []
    end

    test "create_transaction/1 with valid data creates a transaction", %{
      valid_attrs: valid_attrs,
      merchant1: merchant1,
      user1: user1,
      company1: company1
    } do
      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.amount == 42
      assert transaction.credit == false
      assert transaction.debit == true
      assert transaction.description == "some description"
      assert transaction.merchant_id == merchant1.id
      assert transaction.user_id == user1.id
      assert transaction.company_id == company1.id
    end

    test "create_transaction/1 with invalid data returns error changeset", %{
      invalid_attrs: invalid_attrs
    } do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction", %{
      valid_attrs: valid_attrs,
      update_attrs: update_attrs,
      merchant2: merchant2,
      user2: user2,
      company2: company2
    } do
      transaction = transaction_fixture(valid_attrs)

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.amount == 43
      assert transaction.credit == false
      assert transaction.debit == false
      assert transaction.description == "some updated description"
      assert transaction.merchant_id == merchant2.id
      assert transaction.user_id == user2.id
      assert transaction.company_id == company2.id
    end

    test "update_transaction/2 with invalid data returns error changeset", %{
      valid_attrs: valid_attrs,
      invalid_attrs: invalid_attrs
    } do
      transaction = transaction_fixture(valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, invalid_attrs)

      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end

    test "resolver transactions with pagination params" do
      {:ok, transactions } = TransactionsResolver.transactions(nil, %{}, nil)
      assert Enum.count(transactions) == 3
      assert Enum.at(transactions,0).description == "pre-existing transaction"

      {:ok, transactionsLimit2 } = TransactionsResolver.transactions(nil, %{limit: 2}, nil)
      assert Enum.count(transactionsLimit2) == 2
      assert Enum.at(transactionsLimit2,0).description == "pre-existing transaction"

      {:ok, transactionsLimit2Skip2 } = TransactionsResolver.transactions(nil, %{limit: 2, skip: 2}, nil)
      assert Enum.count(transactionsLimit2Skip2) == 1
      assert Enum.at(transactionsLimit2Skip2,0).description == "pre-existing transaction3"

      {:ok, transactionsSkip1 } = TransactionsResolver.transactions(nil, %{skip: 1}, nil)
      assert Enum.count(transactionsSkip1) == 2
      assert Enum.at(transactionsSkip1,0).description == "pre-existing transaction2"
    end

    test "resolver search transactions with pagination params" do
      {:ok, transactions } = TransactionsResolver.search_transactions(nil, %{min: 4, max: 4000}, nil)
      assert Enum.count(transactions) == 3
      assert Enum.at(transactions,0).description == "pre-existing transaction"

      {:ok, transactionsLimit2 } = TransactionsResolver.transactions(nil, %{min: 0, max: 4000, limit: 2}, nil)
      assert Enum.count(transactionsLimit2) == 2
      assert Enum.at(transactionsLimit2,0).description == "pre-existing transaction"

      {:ok, transactionsLimit2Skip2 } = TransactionsResolver.transactions(nil, %{min: 0, max: 4000, limit: 2, skip: 2}, nil)
      assert Enum.count(transactionsLimit2Skip2) == 1
      assert Enum.at(transactionsLimit2Skip2,0).description == "pre-existing transaction3"

      {:ok, transactionsSkip1 } = TransactionsResolver.transactions(nil, %{min: 0, max: 4000, skip: 1}, nil)
      assert Enum.count(transactionsSkip1) == 2
      assert Enum.at(transactionsSkip1,0).description == "pre-existing transaction2"
    end
    # Since this is just giving an example of doing things, I didn't add tests for basic transaction resolvers.
    # But there are resolver tests in companies_tests.exs

  end
end
