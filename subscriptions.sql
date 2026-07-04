-- Run this in Supabase → SQL Editor (after the original schema.sql)

create table if not exists subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  stripe_customer_id text,
  stripe_subscription_id text,
  status text,              -- 'active' | 'trialing' | 'past_due' | 'canceled' | etc.
  price_id text,
  current_period_end timestamptz,
  updated_at timestamptz default now()
);

alter table subscriptions enable row level security;

-- Users can read their own subscription row (needed to show "Subscribed" in the UI)
create policy "Users read their own subscription"
  on subscriptions for select
  using (auth.uid() = user_id);

-- No insert/update/delete policy for regular users on purpose — only the
-- webhook (using the secret key, which bypasses RLS) is allowed to write here.
