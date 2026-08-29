-- migrate:up

-- Small, hand-readable dataset so you can predict query results while practicing.
 
-- CAMPUSES
INSERT INTO campuses (id, name, code) VALUES
  ('camp_jal', 'Main Campus Jalandhar', 'main'),
  ('camp_moh', 'Mohali Campus', 'mohali'),
  ('camp_amr', 'Amritsar Campus', 'amritsar');
 
-- AFFILIATED COLLEGES
INSERT INTO affiliated_colleges (id, name, is_approved) VALUES
  ('affc_gndec', 'GNDEC Ludhiana', true),
  ('affc_bcet', 'BCET Gurdaspur', true);
 
-- STAFF
INSERT INTO staff (id, name, email, password_hash, role, campus_id, is_verified) VALUES
  ('staff_admin', 'Admin One', 'admin@ptu.ac.in', 'hash1', 'ADMIN', NULL, true),
  ('staff_sub_moh', 'Sub Admin Mohali', 'subadmin.mohali@ptu.ac.in', 'hash2', 'SUB_ADMIN', 'camp_moh', true),
  ('staff_coord', 'Coordinator Jal', 'coord.jal@ptu.ac.in', 'hash3', 'COORDINATOR', 'camp_jal', true);
 
-- ACADEMIC OPTIONS (canonical branch/course values post-normalization)
INSERT INTO academic_options (id, type, value, is_active) VALUES
  ('ao_cse', 'BRANCH', 'Computer Science and Engineering', true),
  ('ao_ece', 'BRANCH', 'Electronics and Communication Engineering', true),
  ('ao_ca', 'BRANCH', 'Computer Applications', true),
  ('ao_btech', 'COURSE', 'B.Tech', true),
  ('ao_mca', 'COURSE', 'MCA', true);
 
-- ALUMNI
INSERT INTO alumni (id, name, email, batch_year, branch, college, course, current_job_role, current_company, city, campus_id, is_registered, invite_status, needs_review) VALUES
  ('al_riya', 'Riya Sharma', 'riya.sharma@example.com', 2022, 'Computer Science and Engineering', 'IKGPTU Main Campus', 'B.Tech', 'Backend Engineer', 'TCS', 'Ludhiana', 'camp_jal', true, 'REGISTERED', false),
  ('al_arjun', 'Arjun Mehta', 'arjun.mehta@example.com', 2021, 'Electronics and Communication Engineering', 'IKGPTU Main Campus', 'B.Tech', 'SDE II', 'Infosys', 'Mohali', 'camp_moh', true, 'REGISTERED', false),
  ('al_simran', 'Simran Kaur', 'simran.kaur@example.com', 2023, 'Computer Applications', 'GNDEC Ludhiana', 'MCA', NULL, 'Not Specified', 'Amritsar', 'camp_amr', false, 'INVITED', false),
  ('al_karan', 'Karan Verma', 'karan.verma@example.com', 2020, 'CSE', 'IKGPTU Main Campus', 'B.Tech', 'Founder', 'Self-employed', 'Jalandhar', 'camp_jal', true, 'REGISTERED', true),
  ('al_neha', 'Neha Gupta', 'neha.gupta@example.com', 2022, 'Computer Science and Engineering', 'BCET Gurdaspur', 'B.Tech', 'Data Analyst', 'Wipro', 'Gurdaspur', 'camp_jal', true, 'REGISTERED', false);
 
-- REGISTRATION REQUESTS (pending approval queue)
INSERT INTO registration_requests (id, name, email, batch_year, branch, college, course, auth_provider, status, needs_review) VALUES
  ('rr_ankit', 'Ankit Rana', 'ankit.rana@example.com', 2024, 'Comp. Sci. & Engg.', 'IKGPTU Main Campus', 'B.Tech', 'MANUAL', 'PENDING', true),
  ('rr_pooja', 'Pooja Thakur', 'pooja.thakur@example.com', 2023, 'Electronics and Communication Engineering', 'IKGPTU Main Campus', 'B.Tech', 'GOOGLE', 'PENDING', false),
  ('rr_sahil', 'Sahil Bansal', 'sahil.bansal@example.com', 2022, 'Information Technology', 'GNDEC Ludhiana', 'MCA', 'MANUAL', 'PENDING', true);
 
-- EVENTS
INSERT INTO events (id, title, description, category, event_date, venue, is_published, posted_by_staff_id) VALUES
  ('ev_meet2026', 'Alumni Meet 2026', 'Annual alumni gathering', 'Reunion', '2026-11-15 10:00:00+05:30', 'Main Campus Auditorium', true, 'staff_admin'),
  ('ev_webinar', 'Career Webinar: Backend Systems', 'Panel with alumni engineers', 'Webinar', '2026-09-20 18:00:00+05:30', 'Online', true, 'staff_coord'),
  ('ev_sports', 'Sports Day', 'Inter-batch sports meet', 'Sports', '2026-12-05 09:00:00+05:30', 'Mohali Campus Ground', false, 'staff_sub_moh');
 
-- RSVPS
INSERT INTO rsvps (id, alumni_id, event_id, status) VALUES
  ('rsvp_1', 'al_riya', 'ev_meet2026', 'ATTENDING'),
  ('rsvp_2', 'al_arjun', 'ev_meet2026', 'MAYBE'),
  ('rsvp_3', 'al_neha', 'ev_webinar', 'ATTENDING'),
  ('rsvp_4', 'al_karan', 'ev_meet2026', 'NOT_ATTENDING');
 
-- JOBS
INSERT INTO jobs (id, title, description, company, category, is_active, posted_by_alumni_id) VALUES
  ('job_be', 'Backend Engineer', 'Node.js + Postgres role', 'TCS', 'VACANCY', true, 'al_riya'),
  ('job_drive', 'Campus Drive - SDE', 'On-campus placement drive', 'Infosys', 'ACTIVE_DRIVE', true, NULL),
  ('job_da', 'Data Analyst', 'SQL heavy analytics role', 'Wipro', 'VACANCY', false, 'al_neha');
 
-- CONNECTIONS
INSERT INTO connections (id, sender_id, receiver_id, status) VALUES
  ('conn_1', 'al_riya', 'al_arjun', 'ACCEPTED'),
  ('conn_2', 'al_neha', 'al_riya', 'PENDING'),
  ('conn_3', 'al_karan', 'al_arjun', 'REJECTED');
 
-- ALUMNI FOLLOWS
INSERT INTO alumni_follows (follower_id, following_id) VALUES
  ('al_neha', 'al_riya'),
  ('al_arjun', 'al_riya'),
  ('al_simran', 'al_karan'),
  ('al_riya', 'al_karan');
 
-- NOTIFICATIONS
INSERT INTO notifications (id, type, title, body, audience_tag, channel, created_by_id) VALUES
  ('notif_announce', 'ADMIN_ANNOUNCEMENT', 'Alumni Meet 2026', 'Registrations are now open', 'campus:camp_jal', 'PUSH_AND_INAPP', 'staff_admin'),
  ('notif_follow', 'FOLLOW', 'New follower', 'Neha Gupta started following you', 'user:al_riya', 'INAPP_ONLY', NULL);
 
-- NOTIFICATION STATES
INSERT INTO notification_states (id, user_id, notification_id, is_read) VALUES
  ('ns_1', 'al_riya', 'notif_announce', false),
  ('ns_2', 'al_arjun', 'notif_announce', true),
  ('ns_3', 'al_riya', 'notif_follow', false);
 
-- NORMALIZATION MERGE LOG (audit trail example)
INSERT INTO normalization_merge_logs (id, field, from_values, to_value, affected_ids, performed_by) VALUES
  ('nml_1', 'branch', '["CSE","Comp. Sci. & Engg.","Computer Science & Engineering"]', 'Computer Science and Engineering', '["alumni:al_karan","req:rr_ankit"]', 'staff_admin');



-- migrate:down

DELETE FROM normalization_merge_logs WHERE id = 'nml_1';
DELETE FROM notification_states WHERE id IN ('ns_1','ns_2','ns_3');
DELETE FROM notifications WHERE id IN ('notif_announce','notif_follow');
DELETE FROM alumni_follows WHERE (follower_id, following_id) IN (
  ('al_neha','al_riya'), ('al_arjun','al_riya'), ('al_simran','al_karan'), ('al_riya','al_karan')
);
DELETE FROM connections WHERE id IN ('conn_1','conn_2','conn_3');
DELETE FROM jobs WHERE id IN ('job_be','job_drive','job_da');
DELETE FROM rsvps WHERE id IN ('rsvp_1','rsvp_2','rsvp_3','rsvp_4');
DELETE FROM events WHERE id IN ('ev_meet2026','ev_webinar','ev_sports');
DELETE FROM registration_requests WHERE id IN ('rr_ankit','rr_pooja','rr_sahil');
DELETE FROM alumni WHERE id IN ('al_riya','al_arjun','al_simran','al_karan','al_neha');
DELETE FROM academic_options WHERE id IN ('ao_cse','ao_ece','ao_ca','ao_btech','ao_mca');
DELETE FROM staff WHERE id IN ('staff_admin','staff_sub_moh','staff_coord');
DELETE FROM affiliated_colleges WHERE id IN ('affc_gndec','affc_bcet');
DELETE FROM campuses WHERE id IN ('camp_jal','camp_moh','camp_amr');