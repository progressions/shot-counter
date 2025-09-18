BEGIN;

INSERT INTO campaigns (
  id, user_id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  'f3c41e34-408a-4a6f-8af0-f7cb45b0355e',
  (SELECT id FROM users WHERE email = 'progressions@gmail.com' OR admin = true ORDER BY created_at LIMIT 1),
  'Master Template Campaign',
  NULL,
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
