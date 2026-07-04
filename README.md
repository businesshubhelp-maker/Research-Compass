# Thesis Compass — Web App Scaffold

This is a working foundation: real accounts (signup/login/logout), a protected
dashboard, and a Postgres database with per-user data isolation via Supabase
row-level security. It replaces the local-storage-only auth from the original
prototype.

**What's included:** auth, onboarding/profile form, database schema.
**What's not ported yet:** the 3-step chapter-structure wizard, the chapter
accordion with the writing editor + AI Copilot, the literature review matrix,
Word export, and the Arabic/English language toggle. Those are large pieces —
best done next in Claude Code, where you have real npm/git/deploy tooling to
iterate quickly. This scaffold gives you the auth + data layer to build them on.

## 1. Create a Supabase project
1. Go to https://supabase.com → New Project (free tier is fine).
2. In the SQL Editor, paste and run `supabase/schema.sql` from this repo.
3. Go to Settings → API and copy the **Project URL** and **anon public key**.
4. Go to Authentication → Providers → make sure Email is enabled. Under
   Authentication → Settings you can turn OFF "Confirm email" while testing
   locally so signup logs you straight in.

## 2. Configure environment variables
```
cp .env.example .env.local
```
Paste your Supabase URL and anon key into `.env.local`.

## 3. Run it locally
```
npm install
npm run dev
```
Visit http://localhost:3000 → you'll land on /login. Create an account, and
you should see the onboarding form, then the dashboard.

## 4. Deploy to Vercel
```
npm i -g vercel
vercel
```
Add the same two environment variables in the Vercel project settings
(Settings → Environment Variables), then redeploy.

## 5. Add paid subscriptions (Stripe)

**Setup:**
1. Create a free account at https://stripe.com — stay in **Test mode** (toggle top-right) while developing.
2. Go to **Product catalog → Add product**. Name it (e.g. "Thesis Compass Pro"), set a recurring price
   (e.g. $9/month), and save. Copy the **Price ID** (starts with `price_...`).
3. Go to **Developers → API keys**, copy your **Secret key** (`sk_test_...`).
4. In Supabase SQL Editor, run `supabase/subscriptions.sql` to add the subscriptions table.
5. In Supabase → Settings → API Keys, copy your **Secret key** (`sb_secret_...`, not the publishable one).
6. Fill in `.env.local` with: `STRIPE_SECRET_KEY`, `STRIPE_PRICE_ID`, `SUPABASE_SECRET_KEY`.

**Webhook (tells your app when someone actually pays):**
- **Locally:** install the Stripe CLI (https://stripe.com/docs/stripe-cli), run:
  ```
  stripe listen --forward-to localhost:3000/api/webhook
  ```
  It will print a `whsec_...` value — put that in `.env.local` as `STRIPE_WEBHOOK_SECRET`. Keep this
  command running in a separate terminal alongside `npm run dev` whenever you're testing checkout.
- **In production (after deploying to Vercel):** Stripe dashboard → Developers → Webhooks → Add endpoint
  → URL = `https://your-domain.vercel.app/api/webhook` → select events `checkout.session.completed`,
  `customer.subscription.updated`, `customer.subscription.deleted`. Copy the signing secret it gives you
  into your Vercel environment variables as `STRIPE_WEBHOOK_SECRET`.

**Test it:** run the app, sign up, you'll be redirected to `/pricing`. Click Subscribe, and on Stripe's
checkout page use test card `4242 4242 4242 4242`, any future expiry, any CVC. After payment you'll land
back on `/dashboard`, now unlocked. The "Manage billing" button lets you cancel/update the test subscription.

**Going live:** switch Stripe out of Test mode, create a live product/price, and swap in the live
(`sk_live_...`) keys and a live webhook endpoint in your production environment variables.

## 6. Next build steps (recommended order)
1. **Chapter wizard** — port the 3-step method/mediator/field questionnaire
   from the prototype into `app/dashboard/structure/page.js`.
2. **Sections table wiring** — each chapter/section's written content reads
   and writes to the `sections` table (`chapter_index`, `section_index`,
   `content`) scoped to `auth.uid()`, instead of `localStorage`.
3. **Literature matrix** — port to `app/dashboard/literature/page.js`,
   backed by the `literature_rows` table.
4. **AI Copilot calls** — move the Anthropic API calls into a Next.js API
   route (`app/api/copilot/route.js`) so your API key stays server-side,
   rather than calling the API directly from the browser.
5. **Word export** — keep the client-side export logic, just source the
   content from Supabase instead of local storage.
6. **i18n** — the Arabic/English toggle and RTL layout can be ported as-is;
   consider `next-intl` if you want URL-based locale routing later.
