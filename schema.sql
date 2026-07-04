-- Run this in Supabase → SQL Editor (one time setup)

-- 1. Profile / thesis metadata (one row per user)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  thesis_title text,
  supervisor text,
  university text,
  deadline date,
  method text,       -- 'quant' | 'pls' | 'qual' | 'mixed'
  has_mediator text,  -- 'yes' | 'no'
  field text,
  updated_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Users manage their own profile"
  on profiles for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- 2. Written content for each chapter/section
create table if not exists sections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  chapter_index int not null,
  section_index int not null,
  content text default '',
  updated_at timestamptz default now(),
  unique (user_id, chapter_index, section_index)
);

alter table sections enable row level security;

create policy "Users manage their own sections"
  on sections for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 3. Literature review matrix rows
create table if not exists literature_rows (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  author text, year text, title text, journal text, country text,
  method text, variables text, findings text, gap text, relevance text,
  sort_order int default 0,
  created_at timestamptz default now()
);

alter table literature_rows enable row level security;

create policy "Users manage their own literature rows"
  on literature_rows for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
