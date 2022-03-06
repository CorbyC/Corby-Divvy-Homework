# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Homework.Repo.insert!(%Homework.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Ecto.Adapters.SQL.query!( # blasting he whole db isn't my favorite but since I'm the only one in here and it's local I'm mostly ok with it.
 Homework.Repo, "DELETE FROM transactions"
)
Ecto.Adapters.SQL.query!(
 Homework.Repo, "DELETE FROM merchants"
)
Ecto.Adapters.SQL.query!(
 Homework.Repo, "DELETE FROM users"
)
Ecto.Adapters.SQL.query!(
 Homework.Repo, "DELETE FROM companies"
)

Homework.Repo.insert!(%Homework.Companies.Company{name: "Bridge Four", credit_line: 5000})
Homework.Repo.insert!(%Homework.Companies.Company{name: "Ghostbloods", credit_line: 400000})
Homework.Repo.insert!(%Homework.Companies.Company{name: "Knights Radiant", credit_line: 120000})

Homework.Repo.insert!(%Homework.Users.User{first_name: "Kaladin", last_name: "Stormblessed", dob: "05-09-1986"})
Homework.Repo.insert!(%Homework.Users.User{first_name: "Dalinar", last_name: "Kholin", dob: "03-12-1955"})
Homework.Repo.insert!(%Homework.Users.User{first_name: "Cephandrius", last_name: "Hoid", dob: "01-04-306"})
Homework.Repo.insert!(%Homework.Users.User{first_name: "Szeth", last_name: "Vallano", dob: "04-08-1980"})
Homework.Repo.insert!(%Homework.Users.User{first_name: "Shallan", last_name: "Davar", dob: "07-02-1984"})

Homework.Repo.insert!(%Homework.Merchants.Merchant{name: "Urithiru", description: "Seat of the Knights Radiant"})
Homework.Repo.insert!(%Homework.Merchants.Merchant{name: "Kharbranth", description: "Definitely a place"})
Homework.Repo.insert!(%Homework.Merchants.Merchant{name: "Thaylenah", description: "Much thay, very wow"})
Homework.Repo.insert!(%Homework.Merchants.Merchant{name: "Lasting Integrity", description: "Home of the Honorspren"})

users = Homework.Users.list_users([])
merchants = Homework.Merchants.list_merchants([])

Homework.Repo.insert!(%Homework.Transactions.Transaction{amount: 300, credit: true, debit: false, merchant: Enum.at(merchants,0), user: Enum.at(users,0), description: "Bought a spear"})
Homework.Repo.insert!(%Homework.Transactions.Transaction{amount: 12, credit: false, debit: true, merchant: Enum.at(merchants,1), user: Enum.at(users,1), description: "New uniform"})
Homework.Repo.insert!(%Homework.Transactions.Transaction{amount: 666, credit: false, debit: true, merchant: Enum.at(merchants,3), user: Enum.at(users,2), description: "Nothing suspicious or anything"})
Homework.Repo.insert!(%Homework.Transactions.Transaction{amount: 60, credit: true, debit: false, merchant: Enum.at(merchants,2), user: Enum.at(users,4), description: "Art supplies"})

IO.puts("Successfully seeded all of the things");
