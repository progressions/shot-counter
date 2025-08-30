BEGIN;

INSERT INTO campaigns (
  id, user_id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  '042486f5-f2ed-4055-91c1-43a0fcb3e374',
  (SELECT id FROM users WHERE email = 'progressions@gmail.com' OR admin = true ORDER BY created_at LIMIT 1),
  'Idempotent Test',
  NULL,
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
