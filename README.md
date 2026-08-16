# Kevin & Kaitlyn Wedding Planner

A shared Progressive Web App for wedding planning with real-time sync.
Wedding date: **Saturday, June 12, 2027.**

## Setup Instructions

### 1. Supabase
1. Create a new project at [supabase.com](https://supabase.com).
2. SQL Editor → paste and run **`supabase/migrations/001_init.sql`** (creates every
   table, RLS policies, realtime, the documents storage bucket, and the starter
   task template + vendor/budget categories).
3. Authentication → Users → **Add user** twice, e.g. `kevin@…` and `kaitlyn@…`,
   each with a password. (Email/password sign-in; no email confirmation needed —
   under Authentication → Providers you can disable "Confirm email" for instant use.)
4. Project Settings → API → copy the **Project URL** and the **anon public** key.

### 2. Environment Variables
Create `.env.local` in the project root:
```
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```
Optional (only if you want the email-notification feature via Resend):
```
RESEND_API_KEY=your_resend_key
NOTIFY_FROM_EMAIL=you@yourdomain.com
NEXT_PUBLIC_APP_URL=https://your-deployed-url
```

### 3. Local development
```bash
npm install
npm run dev
```

### 4. Deploy to Vercel
1. Push this repo to GitHub.
2. Import it in Vercel.
3. Add the same environment variables (step 2) in the Vercel project settings.
4. Deploy. Every push to `main` redeploys automatically.

### 5. Add to phone home screen
1. Open the deployed site in Safari (iOS) or Chrome (Android).
2. Share → **Add to Home Screen**. It installs as "K&K Planner."

## Notes for whoever maintains this
- Names / chat participants live in `lib/people.ts` and `app/messages/page.tsx`.
- Task assignees are in `app/tasks/[phase]/page.tsx` (`allAssignees`).
- The phase windows are in `lib/phases.ts`.
- Vendor→budget auto-sync mapping is in `lib/vendor-budget-map.ts`.

## Features
- Task list (8 phases) with progress, assignees, per-task decisions
- Guest list with RSVP tracking (by headcount)
- Vendors (categories, statuses, ratings, budget auto-sync)
- Budget (categories, items, paid tracking)
- Venue comparison
- Documents (folders, uploads)
- Wedding chat
- Custom countdowns (colorable, drag-to-reorder)
- Real-time sync across devices · installable PWA
