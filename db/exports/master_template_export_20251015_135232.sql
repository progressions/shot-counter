BEGIN;

INSERT INTO campaigns (
  id, user_id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  '23f2e012-0612-4997-80fd-de47d0dbfc57',
  (SELECT id FROM users WHERE email = 'progressions@gmail.com' OR admin = true ORDER BY created_at LIMIT 1),
  'Master Template Campaign',
  NULL,
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
