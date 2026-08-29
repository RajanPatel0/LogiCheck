\restrict dbmate

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: batch_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.batch_status AS ENUM (
    'PROCESSING',
    'UPLOADED',
    'INVITED',
    'COMPLETED',
    'PARTIAL_FAILED'
);


--
-- Name: connection_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.connection_status AS ENUM (
    'PENDING',
    'ACCEPTED',
    'REJECTED'
);


--
-- Name: email_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.email_status AS ENUM (
    'QUEUED',
    'SENT',
    'FAILED',
    'BOUNCED'
);


--
-- Name: email_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.email_type AS ENUM (
    'INVITATION',
    'EVENT_ANNOUNCEMENT',
    'EVENT_REMINDER',
    'REGISTRATION_CONFIRMATION'
);


--
-- Name: gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gender AS ENUM (
    'MALE',
    'FEMALE',
    'OTHER'
);


--
-- Name: invite_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invite_status AS ENUM (
    'PENDING',
    'INVITED',
    'REGISTERED',
    'BOUNCED'
);


--
-- Name: job_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.job_category AS ENUM (
    'VACANCY',
    'ACTIVE_DRIVE'
);


--
-- Name: location_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.location_status AS ENUM (
    'FOUND',
    'NOT_FOUND'
);


--
-- Name: map_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.map_visibility AS ENUM (
    'PUBLIC',
    'ALUMNI_ONLY',
    'HIDDEN'
);


--
-- Name: notification_channel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notification_channel AS ENUM (
    'PUSH_AND_INAPP',
    'INAPP_ONLY'
);


--
-- Name: notification_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notification_type AS ENUM (
    'ADMIN_ANNOUNCEMENT',
    'FOLLOW',
    'ANALYTICS_MILESTONE',
    'POST_CREATED',
    'COMMUNITY_UPDATE'
);


--
-- Name: push_delivery_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.push_delivery_status AS ENUM (
    'PENDING',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);


--
-- Name: request_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


--
-- Name: rsvp_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.rsvp_status AS ENUM (
    'ATTENDING',
    'NOT_ATTENDING',
    'MAYBE'
);


--
-- Name: staff_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.staff_role AS ENUM (
    'ADMIN',
    'SUB_ADMIN',
    'COORDINATOR'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.academic_options (
    id text NOT NULL,
    type text NOT NULL,
    value text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: affiliated_colleges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.affiliated_colleges (
    id text NOT NULL,
    name text NOT NULL,
    is_approved boolean DEFAULT false NOT NULL,
    requested_by text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: album_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.album_images (
    id text NOT NULL,
    album_id text NOT NULL,
    image_url text NOT NULL,
    caption text,
    show_on_landing boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: album_likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.album_likes (
    id text NOT NULL,
    album_id text NOT NULL,
    alumni_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: albums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.albums (
    id text NOT NULL,
    title text NOT NULL,
    description text,
    category text DEFAULT 'College Days'::text NOT NULL,
    alumni_id text,
    posted_by_staff_id text,
    views_count integer DEFAULT 0 NOT NULL,
    is_published boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: alumni; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alumni (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    original_invited_email text,
    enrollment_no text,
    batch_year integer NOT NULL,
    branch text NOT NULL,
    college text NOT NULL,
    course text,
    phone text,
    invite_token text,
    invite_status public.invite_status DEFAULT 'PENDING'::public.invite_status NOT NULL,
    is_registered boolean DEFAULT false NOT NULL,
    google_id text,
    linkedin_id text,
    password_hash text,
    reset_token_hash text,
    reset_token_expires_at timestamp with time zone,
    current_job_role text,
    current_company text,
    city text,
    linkedin_url text,
    avatar_url text,
    bio text,
    is_active boolean DEFAULT true NOT NULL,
    needs_review boolean DEFAULT false NOT NULL,
    dob timestamp with time zone,
    gender public.gender,
    address_line text,
    pincode text,
    country text,
    location_id text,
    map_visibility public.map_visibility DEFAULT 'PUBLIC'::public.map_visibility NOT NULL,
    campus_id text NOT NULL,
    affiliated_college_id text,
    imported_by_id text,
    batch_id text,
    invited_at timestamp with time zone,
    registered_at timestamp with time zone,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    followers_count integer DEFAULT 0 NOT NULL,
    following_count integer DEFAULT 0 NOT NULL,
    notifications_read_at timestamp with time zone
);


--
-- Name: alumni_follows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alumni_follows (
    follower_id text NOT NULL,
    following_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: alumni_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alumni_refresh_tokens (
    id text NOT NULL,
    token character varying(255) NOT NULL,
    alumni_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: campuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campuses (
    id text NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id text NOT NULL,
    content text NOT NULL,
    post_id text NOT NULL,
    alumni_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.connections (
    id text NOT NULL,
    sender_id text NOT NULL,
    receiver_id text NOT NULL,
    status public.connection_status DEFAULT 'PENDING'::public.connection_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: education; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.education (
    id text NOT NULL,
    alumni_id text NOT NULL,
    school text NOT NULL,
    degree text NOT NULL,
    field_of_study text,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone,
    is_current boolean DEFAULT false NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: email_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_logs (
    id text NOT NULL,
    recipient_email text NOT NULL,
    alumni_id text,
    event_id text,
    type public.email_type NOT NULL,
    status public.email_status DEFAULT 'QUEUED'::public.email_status NOT NULL,
    brevo_message_id text,
    error_message text,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: event_rsvps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_rsvps (
    id text NOT NULL,
    event_id text,
    event_name text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    phone text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    category text DEFAULT 'General'::text NOT NULL,
    event_date timestamp with time zone NOT NULL,
    venue text NOT NULL,
    cover_image_url text,
    image_urls jsonb,
    rsvp_deadline timestamp with time zone,
    is_published boolean DEFAULT false NOT NULL,
    show_on_landing boolean DEFAULT false NOT NULL,
    posted_by_staff_id text,
    posted_by_alumni_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: invitation_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitation_batches (
    id text NOT NULL,
    label text NOT NULL,
    csv_filename text,
    total_count integer DEFAULT 0 NOT NULL,
    sent_count integer DEFAULT 0 NOT NULL,
    failed_count integer DEFAULT 0 NOT NULL,
    status public.batch_status DEFAULT 'PROCESSING'::public.batch_status NOT NULL,
    created_by_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    company text NOT NULL,
    location text,
    category public.job_category DEFAULT 'VACANCY'::public.job_category NOT NULL,
    salary_range text,
    apply_url text,
    is_active boolean DEFAULT true NOT NULL,
    posted_by_staff_id text,
    posted_by_alumni_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    expire_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb
);


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.likes (
    id text NOT NULL,
    post_id text NOT NULL,
    alumni_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: newsletters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletters (
    id text NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: normalization_merge_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.normalization_merge_logs (
    id text NOT NULL,
    field text NOT NULL,
    from_values text NOT NULL,
    to_value text NOT NULL,
    affected_ids text NOT NULL,
    performed_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notification_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_states (
    id text NOT NULL,
    user_id text NOT NULL,
    notification_id text NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id text NOT NULL,
    type public.notification_type NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    url text,
    metadata jsonb,
    audience_tag character varying(500) NOT NULL,
    target_user_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    channel public.notification_channel DEFAULT 'INAPP_ONLY'::public.notification_channel NOT NULL,
    filter jsonb,
    push_status public.push_delivery_status,
    push_cursor text,
    total_targets integer,
    sent_count integer DEFAULT 0 NOT NULL,
    failed_count integer DEFAULT 0 NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_by_id text,
    campaign_group_id text
);


--
-- Name: pincode_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pincode_locations (
    id text NOT NULL,
    country text NOT NULL,
    pincode text NOT NULL,
    city text,
    state text,
    country_code text,
    display_name text,
    latitude double precision,
    longitude double precision,
    status public.location_status DEFAULT 'FOUND'::public.location_status NOT NULL,
    source text DEFAULT 'Nominatim'::text NOT NULL,
    last_verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: post_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_images (
    id text NOT NULL,
    image_url text NOT NULL,
    post_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id text NOT NULL,
    content text,
    author_id text,
    posted_by_staff_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: push_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_subscriptions (
    id text NOT NULL,
    user_id text NOT NULL,
    endpoint character varying(500) NOT NULL,
    p256dh text NOT NULL,
    auth text NOT NULL,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: registration_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_requests (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    enrollment_no text,
    id_proof_url text,
    batch_year integer NOT NULL,
    branch text NOT NULL,
    college text NOT NULL,
    course text,
    phone text,
    campus_id text,
    affiliated_college_id text,
    current_job_role text,
    current_company text,
    linkedin_url text,
    dob timestamp with time zone,
    gender public.gender,
    address_line text,
    pincode text,
    city text,
    auth_provider text NOT NULL,
    provider_id text,
    password_hash text,
    status public.request_status DEFAULT 'PENDING'::public.request_status NOT NULL,
    needs_review boolean DEFAULT false NOT NULL,
    rejection_reason text,
    reviewed_by_id text,
    reviewed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: rsvps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rsvps (
    id text NOT NULL,
    alumni_id text NOT NULL,
    event_id text NOT NULL,
    status public.rsvp_status NOT NULL,
    message text,
    responded_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: staff; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    role public.staff_role DEFAULT 'ADMIN'::public.staff_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    otp_hash text,
    otp_expires_at timestamp with time zone,
    is_verified boolean DEFAULT false NOT NULL,
    campus_id text,
    modules jsonb DEFAULT '[]'::jsonb,
    created_by_id text
);


--
-- Name: staff_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_refresh_tokens (
    id text NOT NULL,
    token character varying(255) NOT NULL,
    staff_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: startups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.startups (
    id text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    website_url text,
    logo_url text,
    industry text,
    founded_year integer,
    founder_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_tickets (
    id text NOT NULL,
    ticket_no text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    phone text,
    enrollment_no text,
    category text DEFAULT 'General Support'::text NOT NULL,
    subject text NOT NULL,
    message text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    admin_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: work_experiences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_experiences (
    id text NOT NULL,
    alumni_id text NOT NULL,
    company text NOT NULL,
    title text NOT NULL,
    location text,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone,
    is_current boolean DEFAULT false NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: academic_options academic_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_options
    ADD CONSTRAINT academic_options_pkey PRIMARY KEY (id);


--
-- Name: academic_options academic_options_type_value_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_options
    ADD CONSTRAINT academic_options_type_value_key UNIQUE (type, value);


--
-- Name: affiliated_colleges affiliated_colleges_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliated_colleges
    ADD CONSTRAINT affiliated_colleges_name_key UNIQUE (name);


--
-- Name: affiliated_colleges affiliated_colleges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliated_colleges
    ADD CONSTRAINT affiliated_colleges_pkey PRIMARY KEY (id);


--
-- Name: album_images album_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_images
    ADD CONSTRAINT album_images_pkey PRIMARY KEY (id);


--
-- Name: album_likes album_likes_album_id_alumni_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_likes
    ADD CONSTRAINT album_likes_album_id_alumni_id_key UNIQUE (album_id, alumni_id);


--
-- Name: album_likes album_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_likes
    ADD CONSTRAINT album_likes_pkey PRIMARY KEY (id);


--
-- Name: albums albums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_pkey PRIMARY KEY (id);


--
-- Name: alumni alumni_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_email_key UNIQUE (email);


--
-- Name: alumni_follows alumni_follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni_follows
    ADD CONSTRAINT alumni_follows_pkey PRIMARY KEY (follower_id, following_id);


--
-- Name: alumni alumni_google_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_google_id_key UNIQUE (google_id);


--
-- Name: alumni alumni_invite_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_invite_token_key UNIQUE (invite_token);


--
-- Name: alumni alumni_linkedin_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_linkedin_id_key UNIQUE (linkedin_id);


--
-- Name: alumni alumni_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_pkey PRIMARY KEY (id);


--
-- Name: alumni_refresh_tokens alumni_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni_refresh_tokens
    ADD CONSTRAINT alumni_refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: alumni_refresh_tokens alumni_refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni_refresh_tokens
    ADD CONSTRAINT alumni_refresh_tokens_token_key UNIQUE (token);


--
-- Name: campuses campuses_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campuses
    ADD CONSTRAINT campuses_code_key UNIQUE (code);


--
-- Name: campuses campuses_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campuses
    ADD CONSTRAINT campuses_name_key UNIQUE (name);


--
-- Name: campuses campuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campuses
    ADD CONSTRAINT campuses_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: connections connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_pkey PRIMARY KEY (id);


--
-- Name: connections connections_sender_id_receiver_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_sender_id_receiver_id_key UNIQUE (sender_id, receiver_id);


--
-- Name: education education_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_pkey PRIMARY KEY (id);


--
-- Name: email_logs email_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT email_logs_pkey PRIMARY KEY (id);


--
-- Name: event_rsvps event_rsvps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_rsvps
    ADD CONSTRAINT event_rsvps_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: invitation_batches invitation_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation_batches
    ADD CONSTRAINT invitation_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: likes likes_post_id_alumni_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_alumni_id_key UNIQUE (post_id, alumni_id);


--
-- Name: newsletters newsletters_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters
    ADD CONSTRAINT newsletters_email_key UNIQUE (email);


--
-- Name: newsletters newsletters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters
    ADD CONSTRAINT newsletters_pkey PRIMARY KEY (id);


--
-- Name: normalization_merge_logs normalization_merge_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normalization_merge_logs
    ADD CONSTRAINT normalization_merge_logs_pkey PRIMARY KEY (id);


--
-- Name: notification_states notification_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_states
    ADD CONSTRAINT notification_states_pkey PRIMARY KEY (id);


--
-- Name: notification_states notification_states_user_id_notification_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_states
    ADD CONSTRAINT notification_states_user_id_notification_id_key UNIQUE (user_id, notification_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pincode_locations pincode_locations_country_pincode_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pincode_locations
    ADD CONSTRAINT pincode_locations_country_pincode_key UNIQUE (country, pincode);


--
-- Name: pincode_locations pincode_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pincode_locations
    ADD CONSTRAINT pincode_locations_pkey PRIMARY KEY (id);


--
-- Name: post_images post_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_images
    ADD CONSTRAINT post_images_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: push_subscriptions push_subscriptions_endpoint_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_endpoint_key UNIQUE (endpoint);


--
-- Name: push_subscriptions push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: registration_requests registration_requests_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_requests
    ADD CONSTRAINT registration_requests_email_key UNIQUE (email);


--
-- Name: registration_requests registration_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_requests
    ADD CONSTRAINT registration_requests_pkey PRIMARY KEY (id);


--
-- Name: rsvps rsvps_alumni_id_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rsvps
    ADD CONSTRAINT rsvps_alumni_id_event_id_key UNIQUE (alumni_id, event_id);


--
-- Name: rsvps rsvps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rsvps
    ADD CONSTRAINT rsvps_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: staff staff_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_email_key UNIQUE (email);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);


--
-- Name: staff_refresh_tokens staff_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_refresh_tokens
    ADD CONSTRAINT staff_refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: staff_refresh_tokens staff_refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_refresh_tokens
    ADD CONSTRAINT staff_refresh_tokens_token_key UNIQUE (token);


--
-- Name: startups startups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.startups
    ADD CONSTRAINT startups_pkey PRIMARY KEY (id);


--
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);


--
-- Name: support_tickets support_tickets_ticket_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_ticket_no_key UNIQUE (ticket_no);


--
-- Name: work_experiences work_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_experiences
    ADD CONSTRAINT work_experiences_pkey PRIMARY KEY (id);


--
-- Name: idx_academic_options_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_academic_options_is_active ON public.academic_options USING btree (is_active);


--
-- Name: idx_academic_options_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_academic_options_type ON public.academic_options USING btree (type);


--
-- Name: idx_album_images_album_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_album_images_album_id ON public.album_images USING btree (album_id);


--
-- Name: idx_album_likes_album_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_album_likes_album_id ON public.album_likes USING btree (album_id);


--
-- Name: idx_album_likes_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_album_likes_alumni_id ON public.album_likes USING btree (alumni_id);


--
-- Name: idx_albums_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_albums_alumni_id ON public.albums USING btree (alumni_id);


--
-- Name: idx_albums_posted_by_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_albums_posted_by_staff_id ON public.albums USING btree (posted_by_staff_id);


--
-- Name: idx_alumni_affiliated_college_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_affiliated_college_id ON public.alumni USING btree (affiliated_college_id);


--
-- Name: idx_alumni_batch_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_batch_year ON public.alumni USING btree (batch_year);


--
-- Name: idx_alumni_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_branch ON public.alumni USING btree (branch);


--
-- Name: idx_alumni_campus_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_campus_id ON public.alumni USING btree (campus_id);


--
-- Name: idx_alumni_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_city ON public.alumni USING btree (city);


--
-- Name: idx_alumni_college; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_college ON public.alumni USING btree (college);


--
-- Name: idx_alumni_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_course ON public.alumni USING btree (course);


--
-- Name: idx_alumni_current_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_current_company ON public.alumni USING btree (current_company);


--
-- Name: idx_alumni_current_job_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_current_job_role ON public.alumni USING btree (current_job_role);


--
-- Name: idx_alumni_follows_follower_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_follows_follower_id ON public.alumni_follows USING btree (follower_id);


--
-- Name: idx_alumni_follows_following_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_follows_following_id ON public.alumni_follows USING btree (following_id);


--
-- Name: idx_alumni_gender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_gender ON public.alumni USING btree (gender);


--
-- Name: idx_alumni_invite_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_invite_status ON public.alumni USING btree (invite_status);


--
-- Name: idx_alumni_invite_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_invite_token ON public.alumni USING btree (invite_token);


--
-- Name: idx_alumni_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_is_active ON public.alumni USING btree (is_active);


--
-- Name: idx_alumni_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_location_id ON public.alumni USING btree (location_id);


--
-- Name: idx_alumni_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_name ON public.alumni USING btree (name);


--
-- Name: idx_alumni_original_invited_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_original_invited_email ON public.alumni USING btree (original_invited_email);


--
-- Name: idx_alumni_pincode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_pincode ON public.alumni USING btree (pincode);


--
-- Name: idx_alumni_refresh_tokens_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumni_refresh_tokens_alumni_id ON public.alumni_refresh_tokens USING btree (alumni_id);


--
-- Name: idx_comments_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comments_alumni_id ON public.comments USING btree (alumni_id);


--
-- Name: idx_comments_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comments_post_id ON public.comments USING btree (post_id);


--
-- Name: idx_connections_receiver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_connections_receiver_id ON public.connections USING btree (receiver_id);


--
-- Name: idx_connections_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_connections_sender_id ON public.connections USING btree (sender_id);


--
-- Name: idx_connections_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_connections_status ON public.connections USING btree (status);


--
-- Name: idx_education_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_education_alumni_id ON public.education USING btree (alumni_id);


--
-- Name: idx_email_logs_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_logs_alumni_id ON public.email_logs USING btree (alumni_id);


--
-- Name: idx_email_logs_recipient_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_logs_recipient_email ON public.email_logs USING btree (recipient_email);


--
-- Name: idx_event_rsvps_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_rsvps_email ON public.event_rsvps USING btree (email);


--
-- Name: idx_event_rsvps_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_rsvps_event_id ON public.event_rsvps USING btree (event_id);


--
-- Name: idx_events_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_events_category ON public.events USING btree (category);


--
-- Name: idx_events_event_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_events_event_date ON public.events USING btree (event_date);


--
-- Name: idx_events_posted_by_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_events_posted_by_alumni_id ON public.events USING btree (posted_by_alumni_id);


--
-- Name: idx_events_posted_by_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_events_posted_by_staff_id ON public.events USING btree (posted_by_staff_id);


--
-- Name: idx_jobs_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_category ON public.jobs USING btree (category);


--
-- Name: idx_jobs_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_is_active ON public.jobs USING btree (is_active);


--
-- Name: idx_jobs_posted_by_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_posted_by_alumni_id ON public.jobs USING btree (posted_by_alumni_id);


--
-- Name: idx_jobs_posted_by_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_posted_by_staff_id ON public.jobs USING btree (posted_by_staff_id);


--
-- Name: idx_likes_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_likes_alumni_id ON public.likes USING btree (alumni_id);


--
-- Name: idx_likes_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_likes_post_id ON public.likes USING btree (post_id);


--
-- Name: idx_norm_merge_logs_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_norm_merge_logs_created_at ON public.normalization_merge_logs USING btree (created_at);


--
-- Name: idx_norm_merge_logs_field; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_norm_merge_logs_field ON public.normalization_merge_logs USING btree (field);


--
-- Name: idx_notification_states_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_states_user_id ON public.notification_states USING btree (user_id);


--
-- Name: idx_notifications_audience_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_audience_tag ON public.notifications USING btree (audience_tag);


--
-- Name: idx_notifications_campaign_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_campaign_group_id ON public.notifications USING btree (campaign_group_id);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_created_at ON public.notifications USING btree (created_at);


--
-- Name: idx_notifications_push_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_push_status ON public.notifications USING btree (push_status);


--
-- Name: idx_notifications_target_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_target_user_id ON public.notifications USING btree (target_user_id);


--
-- Name: idx_pincode_locations_lat_lng; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pincode_locations_lat_lng ON public.pincode_locations USING btree (latitude, longitude);


--
-- Name: idx_post_images_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_images_post_id ON public.post_images USING btree (post_id);


--
-- Name: idx_posts_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_author_id ON public.posts USING btree (author_id);


--
-- Name: idx_posts_posted_by_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_posted_by_staff_id ON public.posts USING btree (posted_by_staff_id);


--
-- Name: idx_push_subscriptions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_push_subscriptions_user_id ON public.push_subscriptions USING btree (user_id);


--
-- Name: idx_reg_requests_affiliated_college_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reg_requests_affiliated_college_id ON public.registration_requests USING btree (affiliated_college_id);


--
-- Name: idx_reg_requests_campus_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reg_requests_campus_id ON public.registration_requests USING btree (campus_id);


--
-- Name: idx_reg_requests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reg_requests_status ON public.registration_requests USING btree (status);


--
-- Name: idx_rsvps_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rsvps_event_id ON public.rsvps USING btree (event_id);


--
-- Name: idx_staff_campus_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_staff_campus_id ON public.staff USING btree (campus_id);


--
-- Name: idx_staff_refresh_tokens_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_staff_refresh_tokens_staff_id ON public.staff_refresh_tokens USING btree (staff_id);


--
-- Name: idx_startups_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_startups_founder_id ON public.startups USING btree (founder_id);


--
-- Name: idx_support_tickets_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_tickets_created_at ON public.support_tickets USING btree (created_at);


--
-- Name: idx_support_tickets_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_tickets_email ON public.support_tickets USING btree (email);


--
-- Name: idx_support_tickets_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_support_tickets_status ON public.support_tickets USING btree (status);


--
-- Name: idx_work_experiences_alumni_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_work_experiences_alumni_id ON public.work_experiences USING btree (alumni_id);


--
-- Name: album_images album_images_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_images
    ADD CONSTRAINT album_images_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id) ON DELETE CASCADE;


--
-- Name: album_likes album_likes_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_likes
    ADD CONSTRAINT album_likes_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id) ON DELETE CASCADE;


--
-- Name: album_likes album_likes_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_likes
    ADD CONSTRAINT album_likes_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: albums albums_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: albums albums_posted_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_posted_by_staff_id_fkey FOREIGN KEY (posted_by_staff_id) REFERENCES public.staff(id) ON DELETE CASCADE;


--
-- Name: alumni alumni_affiliated_college_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_affiliated_college_id_fkey FOREIGN KEY (affiliated_college_id) REFERENCES public.affiliated_colleges(id);


--
-- Name: alumni alumni_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.invitation_batches(id);


--
-- Name: alumni alumni_campus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_campus_id_fkey FOREIGN KEY (campus_id) REFERENCES public.campuses(id);


--
-- Name: alumni_follows alumni_follows_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni_follows
    ADD CONSTRAINT alumni_follows_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: alumni_follows alumni_follows_following_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni_follows
    ADD CONSTRAINT alumni_follows_following_id_fkey FOREIGN KEY (following_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: alumni alumni_imported_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_imported_by_id_fkey FOREIGN KEY (imported_by_id) REFERENCES public.staff(id);


--
-- Name: alumni alumni_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni
    ADD CONSTRAINT alumni_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.pincode_locations(id);


--
-- Name: alumni_refresh_tokens alumni_refresh_tokens_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumni_refresh_tokens
    ADD CONSTRAINT alumni_refresh_tokens_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: comments comments_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: connections connections_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: connections connections_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: education education_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: email_logs email_logs_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT email_logs_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id);


--
-- Name: email_logs email_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT email_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: events events_posted_by_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_posted_by_alumni_id_fkey FOREIGN KEY (posted_by_alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: events events_posted_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_posted_by_staff_id_fkey FOREIGN KEY (posted_by_staff_id) REFERENCES public.staff(id);


--
-- Name: invitation_batches invitation_batches_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation_batches
    ADD CONSTRAINT invitation_batches_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.staff(id);


--
-- Name: jobs jobs_posted_by_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_posted_by_alumni_id_fkey FOREIGN KEY (posted_by_alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: jobs jobs_posted_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_posted_by_staff_id_fkey FOREIGN KEY (posted_by_staff_id) REFERENCES public.staff(id);


--
-- Name: likes likes_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: likes likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: notification_states notification_states_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_states
    ADD CONSTRAINT notification_states_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON DELETE CASCADE;


--
-- Name: notification_states notification_states_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_states
    ADD CONSTRAINT notification_states_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.staff(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: post_images post_images_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_images
    ADD CONSTRAINT post_images_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: posts posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: posts posts_posted_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_posted_by_staff_id_fkey FOREIGN KEY (posted_by_staff_id) REFERENCES public.staff(id) ON DELETE CASCADE;


--
-- Name: push_subscriptions push_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: registration_requests registration_requests_affiliated_college_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_requests
    ADD CONSTRAINT registration_requests_affiliated_college_id_fkey FOREIGN KEY (affiliated_college_id) REFERENCES public.affiliated_colleges(id);


--
-- Name: registration_requests registration_requests_campus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_requests
    ADD CONSTRAINT registration_requests_campus_id_fkey FOREIGN KEY (campus_id) REFERENCES public.campuses(id);


--
-- Name: registration_requests registration_requests_reviewed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_requests
    ADD CONSTRAINT registration_requests_reviewed_by_id_fkey FOREIGN KEY (reviewed_by_id) REFERENCES public.staff(id);


--
-- Name: rsvps rsvps_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rsvps
    ADD CONSTRAINT rsvps_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id);


--
-- Name: rsvps rsvps_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rsvps
    ADD CONSTRAINT rsvps_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: staff staff_campus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_campus_id_fkey FOREIGN KEY (campus_id) REFERENCES public.campuses(id);


--
-- Name: staff staff_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.staff(id);


--
-- Name: staff_refresh_tokens staff_refresh_tokens_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_refresh_tokens
    ADD CONSTRAINT staff_refresh_tokens_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(id) ON DELETE CASCADE;


--
-- Name: startups startups_founder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.startups
    ADD CONSTRAINT startups_founder_id_fkey FOREIGN KEY (founder_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- Name: work_experiences work_experiences_alumni_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_experiences
    ADD CONSTRAINT work_experiences_alumni_id_fkey FOREIGN KEY (alumni_id) REFERENCES public.alumni(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict dbmate


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20260829113334'),
    ('20260829114803');
