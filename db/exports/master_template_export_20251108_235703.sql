BEGIN;

INSERT INTO campaigns (
  id, user_id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  '22487921-3cf8-4845-95af-e5b1932545e1',
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
  'fad0b78b-a4b5-4bc6-b7e2-ff753f01a995',
  '22487921-3cf8-4845-95af-e5b1932545e1',
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
  'd06fb50d-a1fb-4fd7-ad15-d985e102ac85',
  '22487921-3cf8-4845-95af-e5b1932545e1',
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
  '692d9aea-5792-464c-a191-9961961c696a',
  '22487921-3cf8-4845-95af-e5b1932545e1',
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
  '059fd212-8c4c-4540-bbc3-65e36abb8b4d',
  '22487921-3cf8-4845-95af-e5b1932545e1',
  'Template Character',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"","Hair Color":"","Style of Dress":"","Melodramatic Hook":""}',
  '{"Guns":0,"Type":"Featured Foe","Speed":0,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":0,"Fortune":0,"Sorcery":0,"Creature":0,"Archetype":"","Toughness":0,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":0,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  '692d9aea-5792-464c-a191-9961961c696a',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- No image attached
INSERT INTO vehicles (
  id, campaign_id, name, action_values,
  active, faction_id,
  created_at, updated_at
) VALUES (
  'aac16dd2-3d35-4833-adad-9de8f670465f',
  '22487921-3cf8-4845-95af-e5b1932545e1',
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
  '296a366b-2acf-44ef-a988-4aac48c362a0',
  '22487921-3cf8-4845-95af-e5b1932545e1',
  '692d9aea-5792-464c-a191-9961961c696a',
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
  '059fd212-8c4c-4540-bbc3-65e36abb8b4d',
  'fad0b78b-a4b5-4bc6-b7e2-ff753f01a995',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '1b2f0db7-61a9-4297-8fd2-60993ff9035a',
  '059fd212-8c4c-4540-bbc3-65e36abb8b4d',
  'd06fb50d-a1fb-4fd7-ad15-d985e102ac85',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
