-- ============================================================
-- Migration: 024_seed_axis_bank_transactions.sql
-- Purpose  : Seed Axis Bank transactions from bank statement
-- Account  : 926020014792242
-- Period   : 01/04/2026 to 20/09/2026
-- Opening  : ₹0.00
-- Closing  : ₹80,104.40
-- ============================================================

insert into public.transactions (
    transaction_date,
    transaction_type,
    amount,
    description,
    account_id,
    organization_id,
    payment_method,
    direction,
    party_name
)
select
    v.transaction_date,
    v.transaction_type,
    v.amount,
    v.description,
    a.id,
    o.id,
    v.payment_method,
    v.direction,
    v.party_name
from (
    values

        -- 01. Initial Funding
        (
            date '2026-04-15',
            'founder_contribution',
            100000.00::numeric,
            'Initial Funding-SM00724168-926020014792242',
            'bank_transfer',
            'credit',
            null::text
        ),

        -- 02. Mallika Share Amount
        (
            date '2026-04-16',
            'founder_contribution',
            10.00::numeric,
            'Mallika Share Amount',
            'bank_transfer',
            'credit',
            'Mallika Kakarla'
        ),

        -- 03. Leela Share Amount
        (
            date '2026-04-17',
            'founder_contribution',
            33000.00::numeric,
            'Leela Share Amount',
            'bank_transfer',
            'credit',
            'Leela Chintala'
        ),

        -- 04. Lakshmi Share Amount
        (
            date '2026-04-23',
            'founder_contribution',
            33000.00::numeric,
            'Lakshmi Share Amount',
            'bank_transfer',
            'credit',
            'Lakshmi Gude'
        ),

        -- 05. Leela Share Amount
        (
            date '2026-04-23',
            'founder_contribution',
            990.00::numeric,
            'Leela Share Amount',
            'bank_transfer',
            'credit',
            'Leela Chintala'
        ),

        -- 06. Sajin Share Amount
        (
            date '2026-04-23',
            'founder_contribution',
            33000.00::numeric,
            'Sajin Share Amount',
            'bank_transfer',
            'credit',
            'Sajin Ruba G'
        ),

        -- 07. Received from Lakshmi Gude
        (
            date '2026-05-24',
            'founder_contribution',
            500000.00::numeric,
            'Received from Lakshmi Gude - APIIC Land Purchased',
            'bank_transfer',
            'credit',
            'Lakshmi Gude'
        ),

        -- 08. Received from Lakshmi Gude
        (
            date '2026-05-25',
            'founder_contribution',
            500000.00::numeric,
            'Received from Lakshmi Gude - APIIC Land Purchased',
            'bank_transfer',
            'credit',
            'Lakshmi Gude'
        ),

        -- 09. Received from Krishna Chaitanya
        (
            date '2026-05-25',
            'founder_contribution',
            1000000.00::numeric,
            'Received from Krishna Chaitanya - APIIC Land Purchased',
            'bank_transfer',
            'credit',
            'Krishna Chaitanya'
        ),

        -- 10. Received from Lakshmi Gude
        (
            date '2026-05-26',
            'founder_contribution',
            500000.00::numeric,
            'Received from Lakshmi Gude - APIIC Land Purchased',
            'bank_transfer',
            'credit',
            'Lakshmi Gude'
        ),

        -- 11. Received from Leela Chintala
        (
            date '2026-05-26',
            'founder_contribution',
            400000.00::numeric,
            'Received from Leela Chintala - APIIC Land Purchased',
            'bank_transfer',
            'credit',
            'Leela Chintala'
        ),

        -- 12. Paid to APIIC
        (
            date '2026-05-26',
            'company_expense',
            2946240.00::numeric,
            'Paid to Vendor APIIC - one and half acre Land Purchased',
            'bank_transfer',
            'debit',
            'APIIC'
        ),

        -- 13. Received from Krishna Chaitanya
        (
            date '2026-06-05',
            'founder_contribution',
            20000.00::numeric,
            'Received from Krishna Chaitanya',
            'bank_transfer',
            'credit',
            'Krishna Chaitanya'
        ),

        -- 14. Received from Leela Chintala
        (
            date '2026-06-16',
            'founder_contribution',
            400.00::numeric,
            'Received from Leela Chintala',
            'bank_transfer',
            'credit',
            'Leela Chintala'
        ),

        -- 15. Received from Leela Chintala
        (
            date '2026-06-16',
            'founder_contribution',
            500.00::numeric,
            'Received from Leela Chintala',
            'bank_transfer',
            'credit',
            'Leela Chintala'
        ),

        -- 16. Paid to APIIC
        (
            date '2026-06-16',
            'company_expense',
            74000.00::numeric,
            'Paid to Vendor APIIC - one and half acre Land Purchased',
            'bank_transfer',
            'debit',
            'APIIC'
        ),

        -- 17. Received from Leela Chintala
        (
            date '2026-07-18',
            'founder_contribution',
            450000.00::numeric,
            'Received from Leela Chintala - For Land Registration',
            'bank_transfer',
            'credit',
            'Leela Chintala'
        ),

        -- 18. Registration Fees
        (
            date '2026-07-18',
            'company_expense',
            300526.00::numeric,
            'Paid to Registration Fees',
            'bank_transfer',
            'debit',
            'Registration'
        ),

        -- 19. Registration Fees
        (
            date '2026-07-18',
            'company_expense',
            20006.00::numeric,
            'Paid to Registration Fees',
            'bank_transfer',
            'debit',
            'Registration'
        ),

        -- 20. Srikanth Salary - July 2026
        (
            date '2026-08-03',
            'company_expense',
            75005.90::numeric,
            'Salary for the Month July 2026',
            'bank_transfer',
            'debit',
            'Srikanth Katragadda'
        ),

        -- 21. Vendor Payment
        (
            date '2026-08-24',
            'company_expense',
            100005.90::numeric,
            'Vendor Payment',
            'bank_transfer',
            'debit',
            null::text
        ),

        -- 22. Received to pay Srikanth salary
        (
            date '2026-09-03',
            'founder_contribution',
            75000.00::numeric,
            'Received to pay salary to Srikanth',
            'bank_transfer',
            'credit',
            'Krishna Chaitanya'
        ),

        -- 23. Srikanth Salary - August 2026
        (
            date '2026-09-04',
            'company_expense',
            75005.90::numeric,
            'Paid Salary for the month Aug 2026',
            'bank_transfer',
            'debit',
            'Srikanth Katragadda'
        ),

        -- 24. Received from Leela
        (
            date '2026-09-07',
            'founder_contribution',
            500000.00::numeric,
            'Received from Leela',
            'bank_transfer',
            'credit',
            'Leela Chintala'
        ),

        -- 25. Harveni Group - Project Licences
        (
            date '2026-09-07',
            'company_expense',
            400000.00::numeric,
            'Paid for Project Licences - 35%',
            'bank_transfer',
            'debit',
            'Harveni Group'
        ),

        -- 26. Property Valuation
        (
            date '2026-09-07',
            'company_expense',
            100005.90::numeric,
            'Paid for Property Valuations',
            'bank_transfer',
            'debit',
            'Small Industries Development'
        ),

        -- 27. Received from Lakshmi
        (
            date '2026-09-08',
            'founder_contribution',
            300000.00::numeric,
            'Received from Lakshmi',
            'bank_transfer',
            'credit',
            'Lakshmi Gude'
        ),

        -- 28. Reimbursement to Chaitanya
        (
            date '2026-09-18',
            'reimbursement',
            305000.00::numeric,
            'Paid to Chaitanya for credit bill used for company expenses',
            'bank_transfer',
            'debit',
            'Chaitanya Chintala'
        ),

        -- 29. Received for AutoCAD Charges
        (
            date '2026-09-19',
            'founder_contribution',
            30000.00::numeric,
            'Received to pay AutoCAD Charges',
            'bank_transfer',
            'credit',
            'Krishna Chaitanya'
        )

) as v(
    transaction_date,
    transaction_type,
    amount,
    description,
    payment_method,
    direction,
    party_name
)
cross join lateral (
    select id
    from public.accounts
    where name = 'Axis Bank'
      and account_type = 'bank'
      and owner = 'company'
    limit 1
) a
cross join lateral (
    select id
    from public.organizations
    where name = 'TerraResin'
    limit 1
) o;
