-- ============================================================
-- Migration: 025_update_pnb_opening_balance.sql
-- Purpose  : Set Punjab National Bank opening balance
-- Balance  : ₹50,000.00
-- ============================================================

update public.accounts
set opening_balance = 50000.00
where name = 'Punjab National Bank'
  and account_type = 'bank'
  and owner = 'company';