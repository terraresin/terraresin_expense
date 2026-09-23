-- Record expenses paid personally by a founder without affecting company banks.
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
            'other',
            'founder_paid_cash',
            'founder_paid_netbanking',
            'founder_paid_upi'
        )
    );