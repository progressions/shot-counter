BEGIN;

INSERT INTO campaigns (
  id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  '57965e57-2b79-474a-95d3-fa3126a4971e',
  'Master Template Campaign',
  NULL,
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
