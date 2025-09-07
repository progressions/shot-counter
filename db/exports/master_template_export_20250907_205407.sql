BEGIN;

INSERT INTO campaigns (
  id, user_id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  '341bab3b-576f-4e2a-b1e3-a624c89f8e5e',
  (SELECT id FROM users WHERE email = 'progressions@gmail.com' OR admin = true ORDER BY created_at LIMIT 1),
  'Master Template Campaign',
  NULL,
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
