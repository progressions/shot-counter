BEGIN;

INSERT INTO campaigns (
  id, user_id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  '5d00545c-4ab2-4411-a7a4-ce9877ffea9a',
  (SELECT id FROM users WHERE email = 'progressions@gmail.com' OR admin = true ORDER BY created_at LIMIT 1),
  'Master Template Campaign',
  NULL,
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  path, prerequisite_id, color, bonus,
  created_at, updated_at
) VALUES (
  '748a2b10-eb06-4fe6-8ac9-d82d3285e50d',
  '5d00545c-4ab2-4411-a7a4-ce9877ffea9a',
  'Test Schtick',
  NULL,
  'Guns',
  NULL,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, description, damage, concealment, reload_value,
  juncture, mook_bonus,
  created_at, updated_at
) VALUES (
  'fb95c420-a322-4c47-b4f0-b6a1d5d467fb',
  '5d00545c-4ab2-4411-a7a4-ce9877ffea9a',
  'Test Weapon',
  NULL,
  7,
  NULL,
  NULL,
  NULL,
  0,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- No image attached
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'ae41f23a-992e-4a1d-a66c-0363beabc469',
  '5d00545c-4ab2-4411-a7a4-ce9877ffea9a',
  'Template Faction',
  NULL,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- No image attached
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '2c4beb3d-6a4a-4353-b979-06a7e7cda07f',
  '5d00545c-4ab2-4411-a7a4-ce9877ffea9a',
  'Template Character',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"","Hair Color":"","Style of Dress":"","Melodramatic Hook":""}',
  '{"Guns":0,"Type":"Featured Foe","Speed":0,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":0,"Fortune":0,"Sorcery":0,"Creature":0,"Archetype":"","Toughness":0,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":0,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  'ae41f23a-992e-4a1d-a66c-0363beabc469',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- No image attached
INSERT INTO vehicles (
  id, campaign_id, name, action_values,
  active, faction_id,
  created_at, updated_at
) VALUES (
  '4eabc933-6a96-4a86-8c61-defbc235055d',
  '5d00545c-4ab2-4411-a7a4-ce9877ffea9a',
  'Template Vehicle',
  '{"Type":"PC","Frame":0,"Crunch":0,"Squeal":0,"Pursuer":"true","Handling":0,"Archetype":"Car","Acceleration":0,"Chase Points":0,"Condition Points":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  '44f2f011-ce83-43d9-a610-64c9fdc8955f',
  '5d00545c-4ab2-4411-a7a4-ce9877ffea9a',
  'ae41f23a-992e-4a1d-a66c-0363beabc469',
  'Contemporary',
  NULL,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '2c4beb3d-6a4a-4353-b979-06a7e7cda07f',
  '748a2b10-eb06-4fe6-8ac9-d82d3285e50d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '463d0a56-0703-4910-9d70-3dbf9cbd9251',
  '2c4beb3d-6a4a-4353-b979-06a7e7cda07f',
  'fb95c420-a322-4c47-b4f0-b6a1d5d467fb',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
