-- PNB balance is maintained through transactions, not a seeded balance.
update public.accounts
set opening_balance = 0
where name = 'Punjab National Bank'
  and account_type = 'bank'
  and owner = 'company';