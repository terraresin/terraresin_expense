update public.accounts
set opening_balance = 0
where name = 'Axis Bank'
  and account_type = 'bank'
  and owner = 'company';