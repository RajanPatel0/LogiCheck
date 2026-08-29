-- migrate:up

-- Converted from MySQL/Prisma schema -> PostgreSQL
-- Scope: core identity, alumni, academic-normalization, social graph, events, jobs,
--        notifications, and support tables. Landing-page CMS + Community subsystem
--        are intentionally left out to keep the practice schema focused — same
--        conversion pattern applies if you want to add them later.
 
-- ─────────────────────────────────────────
-- ENUMS
-- (MySQL enum columns -> native Postgres ENUM types)
-- ─────────────────────────────────────────
CREATE TYPE staff_role AS ENUM ('ADMIN', 'SUB_ADMIN', 'COORDINATOR');
CREATE TYPE invite_status AS ENUM ('PENDING', 'INVITED', 'REGISTERED', 'BOUNCED');
CREATE TYPE batch_status AS ENUM ('PROCESSING', 'UPLOADED', 'INVITED', 'COMPLETED', 'PARTIAL_FAILED');
CREATE TYPE rsvp_status AS ENUM ('ATTENDING', 'NOT_ATTENDING', 'MAYBE');
CREATE TYPE email_type AS ENUM ('INVITATION', 'EVENT_ANNOUNCEMENT', 'EVENT_REMINDER', 'REGISTRATION_CONFIRMATION');
CREATE TYPE email_status AS ENUM ('QUEUED', 'SENT', 'FAILED', 'BOUNCED');
CREATE TYPE request_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE gender AS ENUM ('MALE', 'FEMALE', 'OTHER');
CREATE TYPE job_category AS ENUM ('VACANCY', 'ACTIVE_DRIVE');
CREATE TYPE connection_status AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');
CREATE TYPE notification_channel AS ENUM ('PUSH_AND_INAPP', 'INAPP_ONLY');
CREATE TYPE push_delivery_status AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');
CREATE TYPE notification_type AS ENUM ('ADMIN_ANNOUNCEMENT', 'FOLLOW', 'ANALYTICS_MILESTONE', 'POST_CREATED', 'COMMUNITY_UPDATE');
CREATE TYPE location_status AS ENUM ('FOUND', 'NOT_FOUND');
CREATE TYPE map_visibility AS ENUM ('PUBLIC', 'ALUMNI_ONLY', 'HIDDEN');
 
-- ─────────────────────────────────────────
-- IDENTITY / TENANCY
-- ─────────────────────────────────────────
CREATE TABLE campuses (
  id         TEXT PRIMARY KEY,
  name       TEXT UNIQUE NOT NULL,
  code       TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
 
CREATE TABLE affiliated_colleges (
  id           TEXT PRIMARY KEY,
  name         TEXT UNIQUE NOT NULL,
  is_approved  BOOLEAN NOT NULL DEFAULT false,
  requested_by TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
 
CREATE TABLE staff (
  id             TEXT PRIMARY KEY,
  name           TEXT NOT NULL,
  email          TEXT UNIQUE NOT NULL,
  password_hash  TEXT NOT NULL,
  role           staff_role NOT NULL DEFAULT 'ADMIN',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  otp_hash       TEXT,
  otp_expires_at TIMESTAMPTZ,
  is_verified    BOOLEAN NOT NULL DEFAULT false,
  campus_id      TEXT REFERENCES campuses(id),
  modules        JSONB DEFAULT '[]',
  created_by_id  TEXT REFERENCES staff(id)
);
CREATE INDEX idx_staff_campus_id ON staff(campus_id);
 
CREATE TABLE staff_refresh_tokens (
  id         TEXT PRIMARY KEY,
  token      VARCHAR(255) UNIQUE NOT NULL,
  staff_id   TEXT NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_staff_refresh_tokens_staff_id ON staff_refresh_tokens(staff_id);
 
-- ─────────────────────────────────────────
-- ACADEMIC NORMALIZATION
-- ─────────────────────────────────────────
CREATE TABLE academic_options (
  id         TEXT PRIMARY KEY,
  type       TEXT NOT NULL, -- 'BRANCH' | 'COURSE'
  value      TEXT NOT NULL,
  is_active  BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (type, value)
);
CREATE INDEX idx_academic_options_type ON academic_options(type);
CREATE INDEX idx_academic_options_is_active ON academic_options(is_active);
 
CREATE TABLE normalization_merge_logs (
  id           TEXT PRIMARY KEY,
  field        TEXT NOT NULL, -- 'college' | 'branch' | 'course'
  from_values  TEXT NOT NULL, -- JSON array as text
  to_value     TEXT NOT NULL,
  affected_ids TEXT NOT NULL, -- JSON array as text
  performed_by TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_norm_merge_logs_field ON normalization_merge_logs(field);
CREATE INDEX idx_norm_merge_logs_created_at ON normalization_merge_logs(created_at);
 
-- ─────────────────────────────────────────
-- GEO
-- ─────────────────────────────────────────
CREATE TABLE pincode_locations (
  id               TEXT PRIMARY KEY,
  country          TEXT NOT NULL,
  pincode          TEXT NOT NULL,
  city             TEXT,
  state            TEXT,
  country_code     TEXT,
  display_name     TEXT,
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  status           location_status NOT NULL DEFAULT 'FOUND',
  source           TEXT NOT NULL DEFAULT 'Nominatim',
  last_verified_at TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (country, pincode)
);
CREATE INDEX idx_pincode_locations_lat_lng ON pincode_locations(latitude, longitude);
 
-- ─────────────────────────────────────────
-- INVITATION BATCHES
-- ─────────────────────────────────────────
CREATE TABLE invitation_batches (
  id            TEXT PRIMARY KEY,
  label         TEXT NOT NULL,
  csv_filename  TEXT,
  total_count   INTEGER NOT NULL DEFAULT 0,
  sent_count    INTEGER NOT NULL DEFAULT 0,
  failed_count  INTEGER NOT NULL DEFAULT 0,
  status        batch_status NOT NULL DEFAULT 'PROCESSING',
  created_by_id TEXT NOT NULL REFERENCES staff(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at  TIMESTAMPTZ
);
 
-- ─────────────────────────────────────────
-- ALUMNI (core entity)
-- ─────────────────────────────────────────
CREATE TABLE alumni (
  id                        TEXT PRIMARY KEY,
  name                      TEXT NOT NULL,
  email                     TEXT UNIQUE NOT NULL,
  original_invited_email    TEXT,
  enrollment_no             TEXT,
  batch_year                INTEGER NOT NULL,
  branch                    TEXT NOT NULL,
  college                   TEXT NOT NULL,
  course                    TEXT,
  phone                     TEXT,
  invite_token              TEXT UNIQUE,
  invite_status             invite_status NOT NULL DEFAULT 'PENDING',
  is_registered             BOOLEAN NOT NULL DEFAULT false,
  google_id                 TEXT UNIQUE,
  linkedin_id               TEXT UNIQUE,
  password_hash             TEXT,
  reset_token_hash          TEXT,
  reset_token_expires_at    TIMESTAMPTZ,
  current_job_role          TEXT,
  current_company           TEXT,
  city                      TEXT,
  linkedin_url              TEXT,
  avatar_url                TEXT,
  bio                       TEXT,
  is_active                 BOOLEAN NOT NULL DEFAULT true,
  needs_review              BOOLEAN NOT NULL DEFAULT false,
  dob                       TIMESTAMPTZ,
  gender                    gender,
  address_line              TEXT,
  pincode                   TEXT,
  country                   TEXT,
  location_id               TEXT REFERENCES pincode_locations(id),
  map_visibility             map_visibility NOT NULL DEFAULT 'PUBLIC',
  campus_id                 TEXT NOT NULL REFERENCES campuses(id),
  affiliated_college_id     TEXT REFERENCES affiliated_colleges(id),
  imported_by_id            TEXT REFERENCES staff(id),
  batch_id                  TEXT REFERENCES invitation_batches(id),
  invited_at                TIMESTAMPTZ,
  registered_at             TIMESTAMPTZ,
  last_login_at             TIMESTAMPTZ,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
  followers_count           INTEGER NOT NULL DEFAULT 0,
  following_count           INTEGER NOT NULL DEFAULT 0,
  notifications_read_at     TIMESTAMPTZ
);
CREATE INDEX idx_alumni_batch_year ON alumni(batch_year);
CREATE INDEX idx_alumni_branch ON alumni(branch);
CREATE INDEX idx_alumni_college ON alumni(college);
CREATE INDEX idx_alumni_course ON alumni(course);
CREATE INDEX idx_alumni_invite_status ON alumni(invite_status);
CREATE INDEX idx_alumni_invite_token ON alumni(invite_token);
CREATE INDEX idx_alumni_original_invited_email ON alumni(original_invited_email);
CREATE INDEX idx_alumni_campus_id ON alumni(campus_id);
CREATE INDEX idx_alumni_affiliated_college_id ON alumni(affiliated_college_id);
CREATE INDEX idx_alumni_is_active ON alumni(is_active);
CREATE INDEX idx_alumni_city ON alumni(city);
CREATE INDEX idx_alumni_pincode ON alumni(pincode);
CREATE INDEX idx_alumni_name ON alumni(name);
CREATE INDEX idx_alumni_current_company ON alumni(current_company);
CREATE INDEX idx_alumni_current_job_role ON alumni(current_job_role);
CREATE INDEX idx_alumni_gender ON alumni(gender);
CREATE INDEX idx_alumni_location_id ON alumni(location_id);
 
CREATE TABLE alumni_refresh_tokens (
  id         TEXT PRIMARY KEY,
  token      VARCHAR(255) UNIQUE NOT NULL,
  alumni_id  TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_alumni_refresh_tokens_alumni_id ON alumni_refresh_tokens(alumni_id);
 
-- ─────────────────────────────────────────
-- REGISTRATION STAGING
-- ─────────────────────────────────────────
CREATE TABLE registration_requests (
  id                     TEXT PRIMARY KEY,
  name                   TEXT NOT NULL,
  email                  TEXT UNIQUE NOT NULL,
  enrollment_no          TEXT,
  id_proof_url           TEXT,
  batch_year             INTEGER NOT NULL,
  branch                 TEXT NOT NULL,
  college                TEXT NOT NULL,
  course                 TEXT,
  phone                  TEXT,
  campus_id              TEXT REFERENCES campuses(id),
  affiliated_college_id  TEXT REFERENCES affiliated_colleges(id),
  current_job_role       TEXT,
  current_company        TEXT,
  linkedin_url           TEXT,
  dob                    TIMESTAMPTZ,
  gender                 gender,
  address_line           TEXT,
  pincode                TEXT,
  city                   TEXT,
  auth_provider          TEXT NOT NULL,
  provider_id            TEXT,
  password_hash          TEXT,
  status                 request_status NOT NULL DEFAULT 'PENDING',
  needs_review           BOOLEAN NOT NULL DEFAULT false,
  rejection_reason       TEXT,
  reviewed_by_id         TEXT REFERENCES staff(id),
  reviewed_at            TIMESTAMPTZ,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_reg_requests_status ON registration_requests(status);
CREATE INDEX idx_reg_requests_affiliated_college_id ON registration_requests(affiliated_college_id);
CREATE INDEX idx_reg_requests_campus_id ON registration_requests(campus_id);
 
-- ─────────────────────────────────────────
-- PROFILE SUB-ENTITIES
-- ─────────────────────────────────────────
CREATE TABLE education (
  id             TEXT PRIMARY KEY,
  alumni_id      TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  school         TEXT NOT NULL,
  degree         TEXT NOT NULL,
  field_of_study TEXT,
  start_date     TIMESTAMPTZ NOT NULL,
  end_date       TIMESTAMPTZ,
  is_current     BOOLEAN NOT NULL DEFAULT false,
  description    TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_education_alumni_id ON education(alumni_id);
 
CREATE TABLE work_experiences (
  id          TEXT PRIMARY KEY,
  alumni_id   TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  company     TEXT NOT NULL,
  title       TEXT NOT NULL,
  location    TEXT,
  start_date  TIMESTAMPTZ NOT NULL,
  end_date    TIMESTAMPTZ,
  is_current  BOOLEAN NOT NULL DEFAULT false,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_work_experiences_alumni_id ON work_experiences(alumni_id);
 
CREATE TABLE startups (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  description  TEXT NOT NULL,
  website_url  TEXT,
  logo_url     TEXT,
  industry     TEXT,
  founded_year INTEGER,
  founder_id   TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_startups_founder_id ON startups(founder_id);
 
-- ─────────────────────────────────────────
-- EVENTS
-- ─────────────────────────────────────────
CREATE TABLE events (
  id                   TEXT PRIMARY KEY,
  title                TEXT NOT NULL,
  description          TEXT NOT NULL,
  category             TEXT NOT NULL DEFAULT 'General',
  event_date           TIMESTAMPTZ NOT NULL,
  venue                TEXT NOT NULL,
  cover_image_url      TEXT,
  image_urls           JSONB,
  rsvp_deadline        TIMESTAMPTZ,
  is_published         BOOLEAN NOT NULL DEFAULT false,
  show_on_landing      BOOLEAN NOT NULL DEFAULT false,
  posted_by_staff_id   TEXT REFERENCES staff(id),
  posted_by_alumni_id  TEXT REFERENCES alumni(id) ON DELETE CASCADE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_events_posted_by_staff_id ON events(posted_by_staff_id);
CREATE INDEX idx_events_posted_by_alumni_id ON events(posted_by_alumni_id);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_event_date ON events(event_date);
 
CREATE TABLE rsvps (
  id           TEXT PRIMARY KEY,
  alumni_id    TEXT NOT NULL REFERENCES alumni(id),
  event_id     TEXT NOT NULL REFERENCES events(id),
  status       rsvp_status NOT NULL,
  message      TEXT,
  responded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (alumni_id, event_id)
);
CREATE INDEX idx_rsvps_event_id ON rsvps(event_id);
 
CREATE TABLE email_logs (
  id              TEXT PRIMARY KEY,
  recipient_email TEXT NOT NULL,
  alumni_id       TEXT REFERENCES alumni(id),
  event_id        TEXT REFERENCES events(id),
  type            email_type NOT NULL,
  status          email_status NOT NULL DEFAULT 'QUEUED',
  brevo_message_id TEXT,
  error_message   TEXT,
  sent_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_email_logs_recipient_email ON email_logs(recipient_email);
CREATE INDEX idx_email_logs_alumni_id ON email_logs(alumni_id);
 
CREATE TABLE event_rsvps (
  id         TEXT PRIMARY KEY,
  event_id   TEXT,
  event_name TEXT NOT NULL,
  name       TEXT NOT NULL,
  email      TEXT NOT NULL,
  phone      TEXT,
  notes      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_event_rsvps_event_id ON event_rsvps(event_id);
CREATE INDEX idx_event_rsvps_email ON event_rsvps(email);
 
-- ─────────────────────────────────────────
-- FEED (posts / likes / comments / albums)
-- ─────────────────────────────────────────
CREATE TABLE posts (
  id                   TEXT PRIMARY KEY,
  content              TEXT,
  author_id            TEXT REFERENCES alumni(id) ON DELETE CASCADE,
  posted_by_staff_id   TEXT REFERENCES staff(id) ON DELETE CASCADE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_posted_by_staff_id ON posts(posted_by_staff_id);
 
CREATE TABLE post_images (
  id         TEXT PRIMARY KEY,
  image_url  TEXT NOT NULL,
  post_id    TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_post_images_post_id ON post_images(post_id);
 
CREATE TABLE likes (
  id         TEXT PRIMARY KEY,
  post_id    TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  alumni_id  TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (post_id, alumni_id)
);
CREATE INDEX idx_likes_post_id ON likes(post_id);
CREATE INDEX idx_likes_alumni_id ON likes(alumni_id);
 
CREATE TABLE comments (
  id         TEXT PRIMARY KEY,
  content    TEXT NOT NULL,
  post_id    TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  alumni_id  TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_alumni_id ON comments(alumni_id);
 
CREATE TABLE albums (
  id                  TEXT PRIMARY KEY,
  title               TEXT NOT NULL,
  description         TEXT,
  category            TEXT NOT NULL DEFAULT 'College Days',
  alumni_id           TEXT REFERENCES alumni(id) ON DELETE CASCADE,
  posted_by_staff_id  TEXT REFERENCES staff(id) ON DELETE CASCADE,
  views_count         INTEGER NOT NULL DEFAULT 0,
  is_published        BOOLEAN NOT NULL DEFAULT false,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_albums_alumni_id ON albums(alumni_id);
CREATE INDEX idx_albums_posted_by_staff_id ON albums(posted_by_staff_id);
 
CREATE TABLE album_images (
  id             TEXT PRIMARY KEY,
  album_id       TEXT NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  image_url      TEXT NOT NULL,
  caption        TEXT,
  show_on_landing BOOLEAN NOT NULL DEFAULT false,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_album_images_album_id ON album_images(album_id);
 
CREATE TABLE album_likes (
  id         TEXT PRIMARY KEY,
  album_id   TEXT NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  alumni_id  TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (album_id, alumni_id)
);
CREATE INDEX idx_album_likes_album_id ON album_likes(album_id);
CREATE INDEX idx_album_likes_alumni_id ON album_likes(alumni_id);
 
-- ─────────────────────────────────────────
-- JOBS
-- ─────────────────────────────────────────
CREATE TABLE jobs (
  id                   TEXT PRIMARY KEY,
  title                TEXT NOT NULL,
  description          TEXT NOT NULL,
  company              TEXT NOT NULL,
  location             TEXT,
  category             job_category NOT NULL DEFAULT 'VACANCY',
  salary_range         TEXT,
  apply_url            TEXT,
  is_active            BOOLEAN NOT NULL DEFAULT true,
  posted_by_staff_id   TEXT REFERENCES staff(id),
  posted_by_alumni_id  TEXT REFERENCES alumni(id) ON DELETE CASCADE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  expire_at            TIMESTAMPTZ,
  metadata             JSONB DEFAULT '{}'
);
CREATE INDEX idx_jobs_posted_by_staff_id ON jobs(posted_by_staff_id);
CREATE INDEX idx_jobs_posted_by_alumni_id ON jobs(posted_by_alumni_id);
CREATE INDEX idx_jobs_category ON jobs(category);
CREATE INDEX idx_jobs_is_active ON jobs(is_active);
 
-- ─────────────────────────────────────────
-- SOCIAL GRAPH
-- ─────────────────────────────────────────
CREATE TABLE connections (
  id          TEXT PRIMARY KEY,
  sender_id   TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  receiver_id TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  status      connection_status NOT NULL DEFAULT 'PENDING',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (sender_id, receiver_id)
);
CREATE INDEX idx_connections_sender_id ON connections(sender_id);
CREATE INDEX idx_connections_receiver_id ON connections(receiver_id);
CREATE INDEX idx_connections_status ON connections(status);
 
CREATE TABLE alumni_follows (
  follower_id  TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  following_id TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (follower_id, following_id)
);
CREATE INDEX idx_alumni_follows_follower_id ON alumni_follows(follower_id);
CREATE INDEX idx_alumni_follows_following_id ON alumni_follows(following_id);
 
-- ─────────────────────────────────────────
-- NOTIFICATIONS / PUSH
-- ─────────────────────────────────────────
CREATE TABLE push_subscriptions (
  id           TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  endpoint     VARCHAR(500) UNIQUE NOT NULL,
  p256dh       TEXT NOT NULL,
  auth         TEXT NOT NULL,
  user_agent   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_push_subscriptions_user_id ON push_subscriptions(user_id);
 
CREATE TABLE notifications (
  id                 TEXT PRIMARY KEY,
  type               notification_type NOT NULL,
  title              TEXT NOT NULL,
  body               TEXT NOT NULL,
  url                TEXT,
  metadata           JSONB,
  audience_tag       VARCHAR(500) NOT NULL,
  target_user_id     TEXT REFERENCES alumni(id) ON DELETE CASCADE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  channel            notification_channel NOT NULL DEFAULT 'INAPP_ONLY',
  filter             JSONB,
  push_status        push_delivery_status,
  push_cursor        TEXT,
  total_targets      INTEGER,
  sent_count         INTEGER NOT NULL DEFAULT 0,
  failed_count       INTEGER NOT NULL DEFAULT 0,
  started_at         TIMESTAMPTZ,
  completed_at       TIMESTAMPTZ,
  created_by_id      TEXT REFERENCES staff(id) ON DELETE SET NULL,
  campaign_group_id  TEXT
);
CREATE INDEX idx_notifications_audience_tag ON notifications(audience_tag);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_target_user_id ON notifications(target_user_id);
CREATE INDEX idx_notifications_push_status ON notifications(push_status);
CREATE INDEX idx_notifications_campaign_group_id ON notifications(campaign_group_id);
 
CREATE TABLE notification_states (
  id              TEXT PRIMARY KEY,
  user_id         TEXT NOT NULL REFERENCES alumni(id) ON DELETE CASCADE,
  notification_id TEXT NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
  is_read         BOOLEAN NOT NULL DEFAULT false,
  is_deleted      BOOLEAN NOT NULL DEFAULT false,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, notification_id)
);
CREATE INDEX idx_notification_states_user_id ON notification_states(user_id);
 
-- ─────────────────────────────────────────
-- SUPPORT / MISC
-- ─────────────────────────────────────────
CREATE TABLE support_tickets (
  id            TEXT PRIMARY KEY,
  ticket_no     TEXT UNIQUE NOT NULL,
  name          TEXT NOT NULL,
  email         TEXT NOT NULL,
  phone         TEXT,
  enrollment_no TEXT,
  category      TEXT NOT NULL DEFAULT 'General Support',
  subject       TEXT NOT NULL,
  message       TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'PENDING', -- PENDING|IN_PROGRESS|RESOLVED|CLOSED
  admin_notes   TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
CREATE INDEX idx_support_tickets_email ON support_tickets(email);
CREATE INDEX idx_support_tickets_created_at ON support_tickets(created_at);
 
CREATE TABLE newsletters (
  id         TEXT PRIMARY KEY,
  email      TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- migrate:down

-- Drops in reverse dependency order so FK constraints never block a DROP.
 
DROP TABLE IF EXISTS newsletters;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS notification_states;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS push_subscriptions;
DROP TABLE IF EXISTS alumni_follows;
DROP TABLE IF EXISTS connections;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS album_likes;
DROP TABLE IF EXISTS album_images;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS post_images;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS event_rsvps;
DROP TABLE IF EXISTS email_logs;
DROP TABLE IF EXISTS rsvps;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS startups;
DROP TABLE IF EXISTS work_experiences;
DROP TABLE IF EXISTS education;
DROP TABLE IF EXISTS registration_requests;
DROP TABLE IF EXISTS alumni_refresh_tokens;
DROP TABLE IF EXISTS alumni;
DROP TABLE IF EXISTS invitation_batches;
DROP TABLE IF EXISTS pincode_locations;
DROP TABLE IF EXISTS normalization_merge_logs;
DROP TABLE IF EXISTS academic_options;
DROP TABLE IF EXISTS staff_refresh_tokens;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS affiliated_colleges;
DROP TABLE IF EXISTS campuses;
 
DROP TYPE IF EXISTS map_visibility;
DROP TYPE IF EXISTS location_status;
DROP TYPE IF EXISTS notification_type;
DROP TYPE IF EXISTS push_delivery_status;
DROP TYPE IF EXISTS notification_channel;
DROP TYPE IF EXISTS connection_status;
DROP TYPE IF EXISTS job_category;
DROP TYPE IF EXISTS gender;
DROP TYPE IF EXISTS request_status;
DROP TYPE IF EXISTS email_status;
DROP TYPE IF EXISTS email_type;
DROP TYPE IF EXISTS rsvp_status;
DROP TYPE IF EXISTS batch_status;
DROP TYPE IF EXISTS invite_status;
DROP TYPE IF EXISTS staff_role;