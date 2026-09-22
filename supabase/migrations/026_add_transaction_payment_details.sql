-- Add payment rails used by TerraResin transaction entry.
alter table public.transactions
    drop constraint if exists transactions_payment_method_check;

alter table public.transactions
    add constraint transactions_payment_method_check
    check (
        payment_method in (
            'bank_transfer',
            'cash',
            'cheque',
            'upi',
            'imps',
            'neft',
            'rtgs',
            'other'
        )
    );

alter table public.transactions
    add column if not exists cheque_issuer_bank text;
