# Introduction
Hi! I'm Corby Campbell. I finished my BS of Computer Science in 2010 and have done dev since. I took a sorta-break and was a technical team lead 2018-2021 so I was a bit rusty when I got back into dev 6 months ago. I had light exposure to graphQL (I've added a couple basic queries to our graphQL project in node.js, and I of course understand the syntax to query things) but I'd definitely claim junior at best there. Elixir I had 0 experience with, and this exercise has definitely shown how unique it was! (Immutability, yay!) That being said, I feel like I've been able to accomplish a first pass at the majority of the proposed objectives. 

A thing that has been unique is the solitude of it though. I'm a sociable fellow, and I for-reals actually enjoy feedback and being told what I'm doing wrong. Usually when I come to a hard spot or knowledge gap like I did a bunch learning Elixir, I like to reach out to a knowledgeable peer or just ping team chat to solicit opinions. Learning from people is my favorite learning medium, so all book-work form like this was was challenging! (Note I do also love WFH most days. One is able to reach out even from home)

I want to emphasize "first pass" at these objectives. I'm sure they could use tons of error handling, and many of them probably weren't done in the latest and greatest way, or in a way that takes full advantage of Elixir power. Like I said I do really love feedback (I love Radical Candor, a good read if you haven't heard of it), so bring it on!

Anyway, here's what I did! And at least at the time of writing all tests pass and the calls also work in the playground. 

## Write filtering options for transactions, users, and/or merchants. This could include:
  - [x] fuzzy searching for a user by first and last name
  - [x] fuzzy searching for a merchant by name
  - [x] getting back transactions with an amount between min and max arguments  

## Write a new schema, queries, and mutations to add companies to the app
  - [x] users should belong to a company and we should require transactions to pass in a company_id
  - [x] company should have a name, credit_line, and available_credit which would be the credit_line* minus the total amount of transactions for the company
    - *I put an asterisk on this because I feel like I implemented the dynamic credit_line property at the wrong layer. I considered moving it to the resolver layer once I learned more during other objectives (I did this second, after seeding), but ultimately decided it reflected my ability to dive in and figure something out regardless. That being said, in a real world job scenario I love feedback and when some more-experienced person inevitably pointed out it not fitting the correct model, I'd be happy to move it.

## Seed the database. Possible solutions include:
  - [x] Implement provided seeds.ex file
    - I award YOU bonus points if you recognize the theme
  - [ ] Write a .sql file that can be ingested by the database
    - redundant when I had the other way working :P

## Write tests for the resolvers & mutations.  
  - [x] Testing that you can get information from the resolver queries
  - [x] Testing that you can get create/update/delete from the resolver mutations*
    - *Markdown doesn't do half checks... I did all company resolvers, and transaction resolvers for functions with unique functionality (decimals and pagination) but I didn't go through and do all the started object resolvers.

## Add a pagination layer to the queries
  - [x] should include a limit (how many rows to return) and skip (how many rows to skip) options 
    - Did on just transactions and users
  - [ ] should return a total_rows (how many total rows exist)
    - I'd love to discuss the ideal way to implement this! Really I found this is where me being new to Elixir bit the hardest. Generically rather than returning just the object, I'd want to return a wrapper with data.object and data.paginationInfo, maybe add a cursor field so total_rows isn't lonely. But the syntax for and where to tell Pheonix to return something other than the type it's about, eluded me for now. 
  - [x] Bonus: Make it a wrapper* that all the schemas can tap into.
    * My implementation wasn't a wrapper, but it is a generic helper that was easily applied to two different models as an example. A wrapper wlould be even better than my solution for sure.

## Allow the mutations to handle a decimal amount for transactions (the database stores it as cents)
  - [x] Mutations need to convert the Decimal amount to an Integer e.g. 24.68 becomes 2468
  - [x] The queries should convert the Integer amount to a Decimal e.g. 2468 becomes 24.68
    - This section was EXTRA fun in a "I get what's happening but I don't get the Elixir syntax to fix it!" way. I had to add some extra transformation methods so that the unit tests and the playground both worked. They didn't agree on what type 45.5 is.

## Bonus points
  - [x] Find the bug with transactions
  - assuming this was that it wasn't setting credit. I actually accidentally found it while reordering the params to be in the same order in more places. Something which helped as I wqs getting to know the code base.
  - [ ] Find the security issue
    - I'll be honest, security is not my strong suit. I'm happy to understand and implement any of our established security guidelines. But if you leave innovating security up to me we'll be in trouble :D
  - [x] Add/improve the docs and @spec to functions*
    - *Another half check here? I added docs to my new methods, but with my time I put a higher weight on adding functionality than optimising documentation.

All things told I probably spent ~15-20 hours on this. And even if I don't come work with you guys it jumpstarted my graphQL knowledge, which is applicable where I am now, so thanks! 