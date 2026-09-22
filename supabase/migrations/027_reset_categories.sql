-- Replace the initial category list with the TerraResin finance categories.
alter table public.categories
    add column if not exists category_type text,
    add column if not exists description text,
    add column if not exists display_order integer;

-- Existing transactions must remain valid after the category master is reset.
update public.transactions
set category_id = null
where category_id is not null;

delete from public.categories;

insert into public.categories (
    name,
    category_type,
    description,
    display_order,
    organization_id
)
select
    seed.name,
    seed.category_type,
    seed.description,
    seed.display_order,
    organization.id
from (
    values
        (1, 'Plant & Machinery', 'Expense', 'Resin reactors, blenders, pumps, equipment'),
        (2, 'Plant Construction', 'Expense', 'Shed, civil works, flooring, structural works'),
        (3, 'Engineering & Design', 'Expense', 'AutoCAD, plant design, engineering consultancy'),
        (4, 'Electrical Works', 'Expense', 'Electrical panels, wiring, installation'),
        (5, 'Plumbing & Piping', 'Expense', 'Piping, valves, fittings, installation'),
        (6, 'Raw Materials', 'Expense', 'Maleic Anhydride, Phthalic Anhydride, PG, DEG, MEG'),
        (7, 'Chemicals & Additives', 'Expense', 'TPP, DBTO, HQ, wax, catalysts'),
        (8, 'Packaging Materials', 'Expense', 'Drums, cans, bags, labels'),
        (9, 'Transportation & Logistics', 'Expense', 'Freight, transport, loading/unloading'),
        (10, 'Import & Customs', 'Expense', 'Customs duty, clearing, CHA charges'),
        (11, 'Factory Utilities', 'Expense', 'Electricity, water, DG fuel'),
        (12, 'Repairs & Maintenance', 'Expense', 'Machinery and facility repairs'),
        (13, 'Office Expenses', 'Expense', 'Stationery, printing, office supplies'),
        (14, 'Rent & Facility', 'Expense', 'Office/facility rent and maintenance'),
        (15, 'Travel & Accommodation', 'Expense', 'Business travel, hotel, local travel'),
        (16, 'Professional Fees', 'Expense', 'CA, CS, legal, consultancy'),
        (17, 'Government & Statutory Fees', 'Expense', 'APIIC, APPCB, licences, registrations'),
        (18, 'Bank Charges', 'Expense', 'Bank fees, transaction charges'),
        (19, 'Insurance', 'Expense', 'Plant, machinery, employee insurance'),
        (20, 'Software & IT', 'Expense', 'ERP, software, hosting, domain'),
        (21, 'Marketing & Business Development', 'Expense', 'Branding, brochures, exhibitions'),
        (22, 'Salaries & Wages', 'Expense', 'Employee salaries, wages'),
        (23, 'Employee Welfare', 'Expense', 'Food, uniforms, welfare expenses'),
        (24, 'Security & Housekeeping', 'Expense', 'Security, cleaning, housekeeping'),
        (25, 'Communication', 'Expense', 'Mobile, internet, courier'),
        (26, 'Testing & Laboratory', 'Expense', 'Lab testing, QC, certificates'),
        (27, 'Safety & PPE', 'Expense', 'Helmets, gloves, safety equipment'),
        (28, 'Factory Consumables', 'Expense', 'Tools, consumables, general supplies'),
        (29, 'Interest & Finance Costs', 'Expense', 'Loan interest, finance charges'),
        (30, 'Miscellaneous Expenses', 'Expense', 'Other approved business expenses'),
        (31, 'Founder Contribution', 'Income/Contribution', 'Founder deposits money into company bank'),
        (32, 'Founder Reimbursement', 'Liability/Adjustment', 'Company reimburses founder'),
        (33, 'Founder Personal Expense', 'Non-business', 'Personal expense paid through company'),
        (34, 'Bank Transfer', 'Transfer', 'Transfer between company bank accounts'),
        (35, 'Cash Withdrawal', 'Transfer', 'Cash withdrawn from company bank')
) as seed(display_order, name, category_type, description)
cross join lateral (
    select id
    from public.organizations
    where name = 'TerraResin'
    order by created_at
    limit 1
) as organization;

alter table public.categories
    alter column category_type set not null,
    alter column display_order set not null;

alter table public.categories
    add constraint categories_category_type_check
    check (
        category_type in (
            'Expense',
            'Income/Contribution',
            'Liability/Adjustment',
            'Non-business',
            'Transfer'
        )
    );

create index idx_categories_organization_display_order
    on public.categories(organization_id, display_order);