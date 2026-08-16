-- ============================================================================
-- Kevin & Kaitlyn Wedding Planner — full schema + starter seed
-- Wedding date: Saturday, June 12, 2027. No engagement-party features.
-- Run this once in a fresh Supabase project (SQL Editor). Then create the two
-- logins under Authentication > Users.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Tasks
-- ---------------------------------------------------------------------------
CREATE TABLE tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  phase TEXT NOT NULL,
  phase_order INT NOT NULL,
  task_order INT NOT NULL,
  text TEXT NOT NULL,
  category TEXT NOT NULL,
  notes TEXT,
  decision TEXT,
  assigned_to TEXT,
  completed BOOLEAN DEFAULT FALSE,
  completed_by UUID REFERENCES auth.users(id),
  completed_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- Shared notes (single scratchpad row)
-- ---------------------------------------------------------------------------
CREATE TABLE shared_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  text TEXT,
  updated_by UUID REFERENCES auth.users(id),
  updated_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO shared_notes (text) VALUES ('');

-- ---------------------------------------------------------------------------
-- Guests
-- ---------------------------------------------------------------------------
CREATE TABLE guests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  email TEXT[] DEFAULT '{}',
  phone TEXT[] DEFAULT '{}',
  party_size INT NOT NULL DEFAULT 1,
  invitation_sent BOOLEAN NOT NULL DEFAULT FALSE,
  rsvp_received BOOLEAN NOT NULL DEFAULT FALSE,
  attending BOOLEAN,
  meal TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Vendors
-- ---------------------------------------------------------------------------
CREATE TABLE vendor_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE vendors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES vendor_categories(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  contact_name TEXT,
  email TEXT[] DEFAULT '{}',
  phone TEXT[] DEFAULT '{}',
  website TEXT,
  instagram TEXT,
  status TEXT NOT NULL DEFAULT 'Lead',
  estimated_cost NUMERIC,
  quoted_cost NUMERIC,
  deposit_paid NUMERIC,
  first_contact_date DATE,
  last_contact_date DATE,
  next_action_date DATE,
  next_action TEXT,
  recommended_by TEXT,
  rating INT,
  pros TEXT,
  cons TEXT,
  notes TEXT,
  budget_item_id UUID,
  sort_order INT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Budget
-- ---------------------------------------------------------------------------
CREATE TABLE budget_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  total_budget NUMERIC NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO budget_settings (total_budget) VALUES (0);

CREATE TABLE budget_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  allocated NUMERIC NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE budget_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES budget_categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  estimated NUMERIC NOT NULL DEFAULT 0,
  actual NUMERIC NOT NULL DEFAULT 0,
  vendor TEXT,
  paid BOOLEAN NOT NULL DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Event venues (wedding venue candidates)
-- ---------------------------------------------------------------------------
CREATE TABLE event_venues (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT NOT NULL,
  label TEXT NOT NULL,
  venue_name TEXT,
  venue_address TEXT,
  venue_url TEXT,
  event_date TIMESTAMPTZ,
  notes TEXT,
  contact_name TEXT,
  email TEXT[] DEFAULT '{}',
  phone TEXT[] DEFAULT '{}',
  instagram TEXT,
  status TEXT NOT NULL DEFAULT 'Lead',
  estimated_cost NUMERIC,
  quoted_cost NUMERIC,
  deposit_paid NUMERIC,
  first_contact_date DATE,
  last_contact_date DATE,
  next_action_date DATE,
  next_action TEXT,
  recommended_by TEXT,
  rating INT,
  pros TEXT,
  cons TEXT,
  sort_order INT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Documents (files live in the 'documents' storage bucket)
-- ---------------------------------------------------------------------------
CREATE TABLE documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  storage_path TEXT NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  folder TEXT,
  venue_id UUID,
  uploaded_by UUID REFERENCES auth.users(id),
  uploaded_by_email TEXT,
  size_bytes BIGINT,
  mime_type TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Messages (wedding chat)
-- ---------------------------------------------------------------------------
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  user_email TEXT,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Countdowns (custom, drag-orderable, colorable)
-- ---------------------------------------------------------------------------
CREATE TABLE countdowns (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  target_date TIMESTAMPTZ NOT NULL,
  color TEXT NOT NULL DEFAULT '#7B8AA8',
  sort_order INT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- The wedding-day countdown (4:30 PM, June 12, 2027). Stored in US Central;
-- edit it in-app if the couple is in another timezone.
INSERT INTO countdowns (title, target_date, color, sort_order)
VALUES ('Wedding', '2027-06-12 16:30:00-05:00', '#B98487', 0);

-- ============================================================================
-- Row Level Security: any signed-in user has full access (2-person app)
-- ============================================================================
ALTER TABLE tasks              ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_notes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE guests             ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_categories  ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors            ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_settings    ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_categories  ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_items       ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_venues       ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents          ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages           ENABLE ROW LEVEL SECURITY;
ALTER TABLE countdowns         ENABLE ROW LEVEL SECURITY;

CREATE POLICY "auth all" ON tasks             FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON shared_notes      FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON guests            FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON vendor_categories FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON vendors           FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON budget_settings   FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON budget_categories FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON budget_items      FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON event_venues      FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON documents         FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON messages          FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth all" ON countdowns        FOR ALL USING (auth.role() = 'authenticated');

-- ============================================================================
-- Realtime: broadcast changes so both devices stay in sync
-- ============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE shared_notes;
ALTER PUBLICATION supabase_realtime ADD TABLE guests;
ALTER PUBLICATION supabase_realtime ADD TABLE vendor_categories;
ALTER PUBLICATION supabase_realtime ADD TABLE vendors;
ALTER PUBLICATION supabase_realtime ADD TABLE budget_settings;
ALTER PUBLICATION supabase_realtime ADD TABLE budget_categories;
ALTER PUBLICATION supabase_realtime ADD TABLE budget_items;
ALTER PUBLICATION supabase_realtime ADD TABLE event_venues;
ALTER PUBLICATION supabase_realtime ADD TABLE documents;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE countdowns;

-- ============================================================================
-- Storage: private 'documents' bucket + authenticated access
-- ============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "auth read documents"   ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'documents');
CREATE POLICY "auth insert documents" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'documents');
CREATE POLICY "auth update documents" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'documents');
CREATE POLICY "auth delete documents" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'documents');

-- ============================================================================
-- Seed: vendor categories (aligned with the vendor→budget auto-sync map)
-- ============================================================================
INSERT INTO vendor_categories (name, sort_order) VALUES
  ('Venue', 1),
  ('Photography', 2),
  ('Videography', 3),
  ('Florals', 4),
  ('Catering', 5),
  ('Music & Entertainment', 6),
  ('Planning / Coordination', 7),
  ('Hair & Makeup', 8),
  ('Officiant', 9),
  ('Stationery', 10),
  ('Cake / Dessert', 11),
  ('Rentals', 12),
  ('Transportation', 13),
  ('Other', 14);

-- ============================================================================
-- Seed: budget categories (targets of the vendor→budget auto-sync map)
-- ============================================================================
INSERT INTO budget_categories (name, sort_order) VALUES
  ('Venue & Rentals', 1),
  ('Food & Beverage', 2),
  ('Photo & Video', 3),
  ('Florals & Decor', 4),
  ('Music & Entertainment', 5),
  ('Attire & Beauty', 6),
  ('Stationery & Paper', 7),
  ('Transportation & Lodging', 8),
  ('Planning & Coordination', 9),
  ('Misc & Gifts', 10);

-- ============================================================================
-- Seed: 8-phase task template (generic, dated for a June 12, 2027 wedding)
-- ============================================================================
INSERT INTO tasks (phase, phase_order, task_order, text, category, notes) VALUES
('Phase 1: Foundation', 1, 1, 'Set your overall wedding budget together (total $ ceiling + rough category splits)', 'Budget', 'Decide the top-line number before booking anything — everything downstream depends on it.'),
('Phase 1: Foundation', 1, 2, 'Clarify who''s contributing financially and have the conversations', 'Budget', 'Do this before setting the budget number so expectations align.'),
('Phase 1: Foundation', 1, 3, 'Draft a preliminary guest list to confirm your rough headcount (A-list + B-list)', 'Guest List', 'B-list = invited only if A-list declines. Keeps the total manageable.'),
('Phase 1: Foundation', 1, 4, 'Confirm wedding date & weekend', 'Venue', 'Target: Saturday, June 12, 2027.'),
('Phase 1: Foundation', 1, 5, 'Tour venues and compare (aim for 3–5 candidates)', 'Venue', 'Ask about: included rentals, F&B minimums, corkage, vendor restrictions, overtime fees, getting-ready suites.'),
('Phase 1: Foundation', 1, 6, 'Decide: full-service planner, partial planner, or month-of coordinator', 'Planning', 'For hands-on couples, a partial planner hired ~9 months out is the common sweet spot.'),
('Phase 1: Foundation', 1, 7, 'Interview 2–3 planners/coordinators if going that route', 'Planning', 'Ask for references from weddings at your venue shortlist.'),
('Phase 1: Foundation', 1, 8, 'Book venue + sign contract + pay deposit', 'Venue', 'This locks the date. Everything downstream depends on it.'),
('Phase 1: Foundation', 1, 9, 'Start a shared inspiration folder / Pinterest for your aesthetic', 'Design', 'Separate boards: ceremony, reception, florals, attire, details.'),
('Phase 1: Foundation', 1, 10, 'Decide on getting-ready location (hotel suite, venue suite, Airbnb, home)', 'Venue', 'Factor in photo quality of the space — morning light matters.'),
('Phase 1: Foundation', 1, 11, 'Talk through ceremony style: religious, secular, interfaith, officiant type', 'Ceremony', 'If religious, this affects venue + timeline significantly.'),
('Phase 2: Core Vendors', 2, 1, 'Book photographer', 'Photo/Video', 'Top wedding photographers book 12–15 months out. Look for a style you love.'),
('Phase 2: Core Vendors', 2, 2, 'Book videographer', 'Photo/Video', 'Decide: cinematic highlight, documentary, or both. Often the same studio bundles.'),
('Phase 2: Core Vendors', 2, 3, 'Book florist / floral designer', 'Florals', 'For abundant florals, interview designers who specialize in that look.'),
('Phase 2: Core Vendors', 2, 4, 'Book band or DJ', 'Music', 'Decide band vs DJ vs hybrid. Bands book earlier. Live ceremony music is a separate booking.'),
('Phase 2: Core Vendors', 2, 5, 'Book officiant (if not using venue/religious)', 'Ceremony', 'If using a friend, they''ll need to get ordained + registered.'),
('Phase 2: Core Vendors', 2, 6, 'Choose wedding planner/coordinator and sign contract', 'Planning', ''),
('Phase 2: Core Vendors', 2, 7, 'Confirm venue catering OR book external caterer', 'Catering', 'If the venue has in-house catering, confirm menu tasting timing.'),
('Phase 2: Core Vendors', 2, 8, 'Plan a pre-wedding photo shoot (most photographers include one)', 'Photo/Video', 'Doubles as save-the-date photos.'),
('Phase 2: Core Vendors', 2, 9, 'Decide on wedding website platform', 'Communications', 'Withjoy, Zola, and The Knot are all popular — or keep using this app.'),
('Phase 2: Core Vendors', 2, 10, 'Build wedding website skeleton', 'Communications', ''),
('Phase 2: Core Vendors', 2, 11, 'Decide on wedding party composition', 'Wedding Party', ''),
('Phase 2: Core Vendors', 2, 12, 'Ask your wedding party — they plan travel + outfits around this', 'Wedding Party', 'Consider a fun ask: small gift, handwritten note, or photo moment.'),
('Phase 3: Design & Logistics', 3, 1, 'Finalize color palette', 'Design', 'Commit before ordering stationery, linens, or attire.'),
('Phase 3: Design & Logistics', 3, 2, 'Design + order save-the-dates (send 6–8 months before = Oct–Dec 2026)', 'Stationery', 'Send earlier for destination or holiday-adjacent dates.'),
('Phase 3: Design & Logistics', 3, 3, 'Finalize save-the-date guest list + gather all mailing addresses', 'Guest List', 'Single spreadsheet: name, address, email, RSVP, meal, +1, table. This is your master.'),
('Phase 3: Design & Logistics', 3, 4, 'Send save-the-dates', 'Stationery', ''),
('Phase 3: Design & Logistics', 3, 5, 'Order wedding attire — partner 1 (dress/suit)', 'Attire', 'Gowns take 6–9 months + alterations. Don''t wait past Oct 2026.'),
('Phase 3: Design & Logistics', 3, 6, 'Order wedding attire — partner 2 (suit/tux; custom takes 3–4 months)', 'Attire', 'Made-to-measure or a good tailor. Start early.'),
('Phase 3: Design & Logistics', 3, 7, 'Book hair + makeup artist (trial included in most packages)', 'Beauty', ''),
('Phase 3: Design & Logistics', 3, 8, 'Book transportation (getting-ready → venue, shuttles)', 'Logistics', ''),
('Phase 3: Design & Logistics', 3, 9, 'Reserve hotel blocks (2 tiers: nicer + more affordable)', 'Logistics', 'Blocks usually need 10+ rooms.'),
('Phase 3: Design & Logistics', 3, 10, 'Create registry (home goods, experiences, honeymoon fund)', 'Registry', 'Many registries let you mix all three.'),
('Phase 3: Design & Logistics', 3, 11, 'Book rehearsal dinner venue', 'Events', 'Usually the night before the wedding.'),
('Phase 3: Design & Logistics', 3, 12, 'Research + book honeymoon (or at least lock the destination)', 'Honeymoon', 'Ideal windows: right after (June 2027) or a delayed trip later in 2027.'),
('Phase 3: Design & Logistics', 3, 13, 'Start skincare / fitness / wellness routine', 'Personal', ''),
('Phase 3: Design & Logistics', 3, 14, 'Book pre-wedding events: shower, bach/bach parties', 'Events', 'Bach/bach parties typically 2–4 months before the wedding.'),
('Phase 4: Details & Decisions', 4, 1, 'Finalize floral design — arch, centerpieces, aisle, bouquets, installations', 'Florals', 'Splurge call: one big floral moment (ceremony installation or head table).'),
('Phase 4: Details & Decisions', 4, 2, 'Order invitation suite (invite, RSVP, details, envelopes, calligraphy)', 'Stationery', 'Send invites 8–10 weeks out = late March / early April 2027. Calligraphy adds ~4 weeks.'),
('Phase 4: Details & Decisions', 4, 3, 'Decide on day-of paper: menus, place cards, escorts, programs, signage', 'Stationery', 'Order with invitations for design consistency.'),
('Phase 4: Details & Decisions', 4, 4, 'Menu tasting with caterer / venue', 'Catering', 'Ask about: dietary restrictions, kids meals, late-night snacks.'),
('Phase 4: Details & Decisions', 4, 5, 'Finalize bar package (open bar, signature cocktails, wine)', 'Catering', 'A signature cocktail is a fun personal touch.'),
('Phase 4: Details & Decisions', 4, 6, 'Book rentals: linens, chairs, glassware, chargers, napkins', 'Rentals', ''),
('Phase 4: Details & Decisions', 4, 7, 'Book lighting designer or add lighting to rental order', 'Rentals', 'Market lights, uplighting, candles. High-ROI spend.'),
('Phase 4: Details & Decisions', 4, 8, 'First attire fitting', 'Attire', ''),
('Phase 4: Details & Decisions', 4, 9, 'Book photo booth or guest entertainment (optional)', 'Entertainment', ''),
('Phase 4: Details & Decisions', 4, 10, 'Finalize cake / dessert (baker tasting)', 'Catering', ''),
('Phase 4: Details & Decisions', 4, 11, 'Plan ceremony: vows, readings, readers, processional, music', 'Ceremony', ''),
('Phase 4: Details & Decisions', 4, 12, 'Meet with officiant to plan ceremony structure', 'Ceremony', ''),
('Phase 4: Details & Decisions', 4, 13, 'Apply for marriage license (2–4 weeks before)', 'Legal', 'Check your county''s rules — licenses are often valid only 30–60 days.'),
('Phase 4: Details & Decisions', 4, 14, 'Finalize wedding party attire + confirm everyone has ordered', 'Attire', ''),
('Phase 4: Details & Decisions', 4, 15, 'Plan wedding party gifts', 'Wedding Party', ''),
('Phase 4: Details & Decisions', 4, 16, 'Plan partner gifts (morning-of exchange)', 'Personal', ''),
('Phase 5: Home Stretch', 5, 1, 'Send invitations (target early April 2027)', 'Stationery', 'RSVP deadline = ~3 weeks before the wedding.'),
('Phase 5: Home Stretch', 5, 2, 'Finalize honeymoon itinerary, book flights + hotels, passports/visas', 'Honeymoon', ''),
('Phase 5: Home Stretch', 5, 3, 'Hair + makeup trial', 'Beauty', ''),
('Phase 5: Home Stretch', 5, 4, 'Second fitting — partner 1', 'Attire', ''),
('Phase 5: Home Stretch', 5, 5, 'Fitting — partner 2', 'Attire', ''),
('Phase 5: Home Stretch', 5, 6, 'Confirm all vendor contracts, payment schedules, arrival times', 'Vendors', 'Build a vendor contact sheet: name, role, arrival, phone, balance due.'),
('Phase 5: Home Stretch', 5, 7, 'Create day-of timeline (distribute to vendors + wedding party)', 'Planning', 'Hour-by-hour from getting-ready through last shuttle.'),
('Phase 5: Home Stretch', 5, 8, 'Bachelor + bachelorette parties (usually 1–2 months out)', 'Events', ''),
('Phase 5: Home Stretch', 5, 9, 'Bridal / wedding shower (usually ~2 months out)', 'Events', ''),
('Phase 5: Home Stretch', 5, 10, 'Finalize seating chart (as RSVPs come in)', 'Guest List', 'Tools: Prismm, AllSeated, or a simple grid.'),
('Phase 5: Home Stretch', 5, 11, 'Write welcome note / welcome bags for out-of-town guests', 'Logistics', ''),
('Phase 5: Home Stretch', 5, 12, 'Write vows (separately, don''t share until the day)', 'Ceremony', ''),
('Phase 5: Home Stretch', 5, 13, 'Prep toast notes — gently remind parents, best man, MOH', 'Ceremony', ''),
('Phase 5: Home Stretch', 5, 14, 'Order wedding bands if not already done', 'Attire', ''),
('Phase 5: Home Stretch', 5, 15, 'Figure out pet / kid weekend plan (sitter, family, cameo)', 'Personal', ''),
('Phase 6: Final 2 Weeks', 6, 1, 'Chase any missing RSVPs', 'Guest List', ''),
('Phase 6: Final 2 Weeks', 6, 2, 'Give final guest count + meal selections to caterer/venue', 'Catering', ''),
('Phase 6: Final 2 Weeks', 6, 3, 'Final seating chart to printer/calligrapher', 'Stationery', ''),
('Phase 6: Final 2 Weeks', 6, 4, 'Final walkthrough at venue with planner + vendors', 'Venue', ''),
('Phase 6: Final 2 Weeks', 6, 5, 'Confirm hair + makeup call times for wedding party', 'Beauty', ''),
('Phase 6: Final 2 Weeks', 6, 6, 'Pre-pay vendors + prepare tip envelopes (labeled, cash)', 'Budget', 'Tips: photo/video optional or $100–$300; catering ~15–20%; DJ/band $50–$100/musician; H&M ~15–20%; transport ~15–20%.'),
('Phase 6: Final 2 Weeks', 6, 7, 'Pack emergency kit (sewing kit, stain pen, pain reliever, mints)', 'Logistics', ''),
('Phase 6: Final 2 Weeks', 6, 8, 'Pick up marriage license', 'Legal', ''),
('Phase 6: Final 2 Weeks', 6, 9, 'Confirm welcome bags delivered to hotel', 'Logistics', ''),
('Phase 6: Final 2 Weeks', 6, 10, 'Break in wedding shoes', 'Attire', ''),
('Phase 6: Final 2 Weeks', 6, 11, 'Final attire fitting (steaming, pressing)', 'Attire', ''),
('Phase 6: Final 2 Weeks', 6, 12, 'Write thank-you notes for pre-event hosts', 'Personal', ''),
('Phase 6: Final 2 Weeks', 6, 13, 'Pack honeymoon bags', 'Honeymoon', ''),
('Phase 7: Wedding Week & Day-Of', 7, 1, 'Rehearsal + rehearsal dinner', 'Events', ''),
('Phase 7: Wedding Week & Day-Of', 7, 2, 'Bring items to venue: vows, bands, license, place cards, programs', 'Logistics', ''),
('Phase 7: Wedding Week & Day-Of', 7, 3, 'Hand off all day-of coordination to planner/coordinator', 'Planning', ''),
('Phase 7: Wedding Week & Day-Of', 7, 4, 'Get ready with wedding party', 'Beauty', ''),
('Phase 7: Wedding Week & Day-Of', 7, 5, 'First look or first-see moment (if doing one)', 'Photo/Video', ''),
('Phase 7: Wedding Week & Day-Of', 7, 6, 'Ceremony', 'Ceremony', ''),
('Phase 7: Wedding Week & Day-Of', 7, 7, 'Cocktail hour, reception, dances, toasts, cake, send-off', 'Events', ''),
('Phase 7: Wedding Week & Day-Of', 7, 8, 'Delegate: someone brings gifts back, someone takes attire for cleaning', 'Logistics', ''),
('Phase 8: Post-Wedding', 8, 1, 'Leave for honeymoon', 'Honeymoon', ''),
('Phase 8: Post-Wedding', 8, 2, 'Return rentals (suit, shoes, any linens)', 'Logistics', ''),
('Phase 8: Post-Wedding', 8, 3, 'Preserve or clean wedding attire', 'Attire', ''),
('Phase 8: Post-Wedding', 8, 4, 'File marriage license / obtain certified copies', 'Legal', 'Needed for name change + joint accounts.'),
('Phase 8: Post-Wedding', 8, 5, 'Write + send thank-you notes (within ~3 months)', 'Communications', ''),
('Phase 8: Post-Wedding', 8, 6, 'Name change paperwork (SSA, DMV, passport, bank)', 'Legal', ''),
('Phase 8: Post-Wedding', 8, 7, 'Order photo album + share galleries with family', 'Photo/Video', ''),
('Phase 8: Post-Wedding', 8, 8, 'Review exceptional vendors — it really helps them', 'Vendors', '');
