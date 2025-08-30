BEGIN;

INSERT INTO campaigns (
  id, user_id, name, description, is_master_template, active,
  created_at, updated_at
) VALUES (
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  (SELECT id FROM users WHERE email = 'progressions@gmail.com' OR admin = true ORDER BY created_at LIMIT 1),
  'Master Campaign',
  '<p>The master template other campaigns are based on, including Character templates, Schticks, Weapons, and Factions.</p>',
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9a3e51f9-dc2d-438a-a744-43744cbd25df',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Impossibilist',
  'Add 1 shot to the cost of a stunt attack to gain a free Fortune die on it.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0ccf8e59-982b-43ff-b8e7-403fce37332a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rebellious Streak',
  'After taking Wound Points from a boss, add a free Fortune die to your next check.',
  'Redeemed Pirate',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bbae671a-9511-4c19-9b2d-60674d64376a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Signature Weapon',
  'Select one specific gun as a Signature Weapon. Your character might have his lucky Glock, the combat shotgun his grandmother gave to him as a coming of age present, his collector’s edition ankle holster .32, or the like. A character using a Signature Weapon gets a +3 Damage Value bonus with that particular weapon. Note that this applies to a single, actual weapon, not to all identical weapons; your lucky Glock gives you a +3, but any other Glock of the same model is just that: a regular Glock. GM guidance for Signature Weapons appears on p. 302.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b28a164c-0bac-4f36-87d1-902025f0d0b6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Widen the Circle',
  'Spend 1 shot as an interrupt when an ally grants a boost to any other ally. You also gain the benefit of that boost.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1dccd3d2-907a-4cbf-8369-4d17317b415e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Improbability Capacitor',
  'As an interrupt on an ally’s successful attack, spend 1 Fortune and 1 shot. Ally’s attack fails. Don’t roll your next attack; instead use the ally’s result from this attack.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '28bf483c-c35e-42b5-aa86-93ef329c1cd6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Spatial Confusion',
  'Make yourself appear to be where you aren’t, and not where you are.  Spend 1 Magic and 1 shot to check Sorcery against a target’s Will Resistance value. On a success, gain +1 Sorcery and +1 Defense against that target until the next keyframe.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '42e7ccc2-aa97-4a43-ae83-b1585d5a8f1e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Vengeful Arrow',
  'As an interrupt when an ally makes an Up Check, spend 1 shot to make a bow attack against the enemy who last hit the ally.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6e521434-8a26-4e6e-8486-51b9cc344aa6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Apex Predator',
  'After your first successful Martial Arts attack of a sequence, the following attack gets +3 to Martial Arts.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '985ad42b-daf3-4241-8c02-9b142ddcca2c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Adaptive Enzymes',
  'When you take a Mark of Death, spend 1 shot to subtract 10 from your Wound Point total.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a45a696c-5603-477c-91d7-03ff1f34d943',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Skull-Mounted Targeting Goggles',
  'Suitable for: Cyborg.  Add +3 Initiative if Wound Points are less than 20.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9b5698e3-586e-452a-a04c-4b1407093e84',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Protective Fury',
  'Suitable for: Martial Artist.  When a mook is downed by a weapon-wielding hero, the foe may spend 1 shot to Disarm that hero.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e7b2e2fa-8a43-4367-b259-23866de1140d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Very Strong',
  'Spend 1 shot. Until end of fight, add 3 to your Damage on any successful hand-to-hand strike (using your Mutant attack value) including strikes',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '924b2612-2a57-4ee3-bed3-34b7799c1d57',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Numerical Superiority',
  'Add +2 Toughness when more than half the mooks on the foe’s side are still standing.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '39eb2d5c-cb37-4846-a386-07c2c2d5b197',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Force Shield',
  'Spend 1 Genome point and 1 shot; your Defense increases by 1 until end of sequence.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '443b0608-928c-4100-b380-89efceb4c50b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning Reload IV',
  'Add 4 to the results of all Reload Checks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2eb5c0a7-baa8-4b2e-8d90-7bd85b017fbc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Luck of the Fox',
  'Spend 1 Chi and 1 shot. Until the next keyframe, roll a die as an interrupt after adding a Fortune die to any check or to a Dodge. On an even result, regain the Fortune point.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '34c8e546-bde2-4786-a2ce-05f9fcf6c375',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flying Windmill Kick',
  'Spend 4 shots to make a Martial Arts kick attack. If the attack hits, you may make another kick attack on the same opponent at 0 shot cost. You may continue doing this until an attack fails, or until you land a third hit.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8cf81fdd-ed41-48fe-a9d0-04f5c4b2bf75',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pincer II',
  'On a successful bare-handed Martial Arts attack, you deal 13 damage and shot cost of target’s next attack increases by 2. Latter effect not cumulative with previous Pincer attacks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c9b8bff1-cf42-49bd-a076-11cfebb0742a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Neural Stimulator',
  'Add +X Speed until end of fight; take 5 times X Wound Points.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8d848be2-34e9-4b4c-9eac-5d13ba95da00',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Back For Seconds',
  'Shed Wound Points equal to your Toughness +3 on a successful Up Check. You get to add +4 to your next attack.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e22db50f-ec48-40e3-9375-4cfdd19054e8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Underdog Desperation',
  'Add +2 Toughness vs. opponents with fewer Wound Points than you.',
  'Karate Cop',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1c941ea2-289a-4f56-89ae-9d124ba6d645',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pulse Grenade',
  'Any time after the end of sequence 2, spend 3 shots to down all mooks.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '38d7f0d8-0267-4ef0-86a5-3e1bc20e3c66',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Braced for Impact',
  'When the foe’s vehicle crashes, all occupants gain +4 Toughness against crash damage.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '08c0ddb5-ce00-4360-8d5f-04a03d2a4afa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'King on the Water',
  'In a fight under the adverse condition Torrential Rain, spend 1 Chi and 0 shots to gain a +2 Immunity bonus until the end of the fight or the end of the condition.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e739599b-88c1-4a0b-8a62-cfeb5c082b33',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wicked ride',
  'Add 2 to the Handling of the vehicle the foe starts the chase in.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd4f5acfa-d440-4ed4-9551-b5639ff6e098',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Diversion',
  'Spend 1 Chi and 1 shot to make a Martial Arts Check against a foe’s Will Resistance. On a success, the foe loses 4 shots.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0bcdecd1-b1e6-4843-8c18-9a4741d2ba66',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rebuke',
  'Spend 1 Chi. Until end of fight, the battle zone is treated as hostile to Sorcery.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '46cf6436-6511-43f9-97a1-2255163d96e9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bullet Time',
  'Oh wait, that’s just Dodge. Never mind, don’t take this one.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9ff2ec2f-1186-4365-934a-bcbe8e261132',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Preternaturally Aware',
  'Add +3 to all Notice Checks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b2cf18c5-a8ec-45a4-8bda-b0986b3564eb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sting',
  'Spend 1 Chi as an interrupt after making a successful Martial Arts attack. Until end of fight, target takes 3 Wound Points each time it fails an attack.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a523a25a-61ef-469c-943b-b4ed219ee694',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Never Forget',
  'Add +1 Martial Arts vs. opponents you’ve previously fought.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2eef61d1-71b8-4553-8188-8f2ec1fdb1da',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Born in a Cage',
  'After a boss deals you any number of Wound Points, add a free Fortune die to your next check.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '73243abc-5159-4c99-8af3-7f6ae0b8f662',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flesh Wound',
  'When for the first time in a fight you take 10 or more Wound Points, spend 1 shot as an interrupt to reduce Wound Points taken to 1.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd3418666-a998-47fb-adc3-ba14a2ebce03',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Magnetic Blast',
  'When you hit a vehicle with a Chi Blast, it takes +3 Condition Points.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '77fccc90-2276-4b75-a627-00e5d459b44b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Carnival of Carnage II',
  'Add +2 Guns vs. mooks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1f7f9e60-f329-421d-9bb3-71677f763290',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Quick Domination',
  'Spend 1 Magic and X shots; make a Sorcery Check with a creature’s Will Resistance value as the Difficulty. The creature fights as your ally for X shots, attacking targets you designate. Does not work on bosses or uber-bosses.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6009eee5-e0b0-44e3-8cac-03293f5a3054',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Harsh Switcheroo',
  'As an interrupt when an enemy is hit by an attack, spend 1 shot and make a Sorcery Check against the Defense of another enemy. On a success, the second enemy takes the hit instead. Use the new recipient’s Toughness to determine how many Wound Points get dished out.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c2e97d4e-9d77-49be-adf9-e9d0831d2480',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Esoteric Art of Speed-Drinking',
  'Spend 1 shot to consume two servings of alcohol.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2cc7fb75-144e-4d15-b4fd-0e2fa83c2f01',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mjolnirification',
  'Spend 1 shot to make any dropped or unattended weapon teleport into your hand.  Weapons in a Bag Full of Guns are not unattended.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c102ecbe-b039-4a34-aea1-1d574f3ed858',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Eagle Eye',
  'Add +X to the shot cost of a Guns attack to gain +X Guns for that attack. X cannot exceed 3.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3922ed20-b6ec-4085-bbc6-4bff8ac4f9e5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Observe Chi',
  'See the flow of chi in an area, noting how strong or weak it is and if it is corrupted or impinged upon by some unnatural force. Immediately identify feng shui sites. Tell whether an individual you can see in person is attuned to at least one feng shui site.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '20b392e9-5a60-4049-acef-8c1592bb4152',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Henhouse prowl',
  'As an interrupt when an ally deals Wound Points to an enemy, spend 1 Chi to redirect the Wound Points to a different enemy.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3d9e0fb2-db2e-42a3-bd2e-463f086d7b6d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Some Damn Thing With Playing Cards',
  'When an ally misses an attack, spend 2 shots to allow the ally to attack again as a 0-shot interrupt.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '359197d8-7fff-41b6-9713-4f319de23587',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lucky 8 Blast',
  'As per Chi Blast. On an Outcome of 4 or more, regain 1 spent Magic.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5f2c35a2-d354-41cb-a98f-fdc7a42ad3d6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Friend of Darkness',
  'When attacking an opponent for the first time in the current fight, treat the opponent’s Toughness as 4. This is inapplicable if opponent’s Toughness is less than 4.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9ccb1dbd-12b0-46c9-bd04-110e3134e907',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Showy Arrow I',
  'As an interrupt when an ally hits with a Guns attack, spend 1 Fortune and 2 shots to make a Guns attack with bow and arrow against the same target.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5fd0a1c2-2639-4b76-9d67-9f2bacce3dc3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lair Dweller',
  'Add +1 to Martial Arts and Defense if you arrived at the fight’s location before the other side did.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f4a25039-594b-4b2d-9855-57cd299d17a0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Balance Bringer',
  'Add +2 Martial Arts and +2 Toughness vs. foes with Sorcery or Creature Powers attacks.',
  'Exorcist Monk',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3c5d0fa1-1afa-4f0b-ace6-5e51fcb8f263',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shred the False Veil',
  'If you damage an opponent disguised by magic or sorcery, it reverts to its true form. If you down a transformed animal foe, it reverts to its animal form. If you down a supernatural creature, it is immediately banished to the spirit realm and can never return to the present juncture.',
  'Exorcist Monk',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ac3fe2a9-3b8d-44c3-8236-2532f6680193',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Glutton for Punishment',
  'When you take Wound Points from a Martial Arts attack, or take non-attack damage, your next Martial Arts attack this fight gets a +2 bonus. This bonus stacks with other effects but not with itself.',
  'Karate Cop',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '63115496-cb41-49c8-8f19-4df330907f5b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tremble, Evildoers!',
  'When you attack a single mook and drop it, 4 other mooks Cheese It. If your positive die exploded, a total of 6 mooks Cheese It.',
  'Masked Avenger',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6e60fa3f-5b4e-410c-9dff-fae777677d7a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Crane Stance',
  'Whenever a mook hits you, attack the mook as an interrupt.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '92ce7676-8b47-4147-8af3-dd042f89f1c7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Healthy as a Horse II',
  'You get a +4 bonus to Constitution Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5d2eb7f6-12b7-4273-a6f5-861a1f4da79f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Reinforced Skeleton',
  'Suitable for: Scroungetech, Mutant, Supernatural Creature.  On a failed Martial Arts attack against the foe, the attacker takes Wound Points equal to the difference between result and the defender’s Defense.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c3787c2a-dc3e-461a-95cd-f6b4c1cd2503',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stunt Stopper',
  'As an interrupt when a hero announces a stunt, spend 3 shots to make an attack against the hero.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'aca9e1ff-d082-425e-ad24-b429d0944a51',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Versatile Master',
  'Gain +2 to your first Martial Arts attack after switching from one weapon to another you have yet to use in the current fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c67c5066-5b64-4447-b7d8-9987b9dcaf34',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Noctilucent',
  'Spend 1 Genome point to brightly glow until end of scene or end of fight, whichever comes first. +2 Defense vs. close attacks, -2 Defense vs. ranged attacks.  Neither you nor allies within close range suffer penalties from the adverse condition Darkness.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b7cb114c-871d-41e5-b4d7-6f9de7e311ee',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Helix Rethreader',
  'Spend 3 shots; until the next keyframe, any named combatant (including you) who makes a failed attack takes 5 Wound Points.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '618fdc68-613a-4bab-823d-e385c2645df4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bag Full of Guns I',
  'Start each fight with a revolver (9/2/6). Each time you fail an attack roll, spend 0 shots to move to the next item in this gun list: Colt 1911A (10/2/4), Desert Eagle .357 Magnum (11/3/3), Chiappa Rhino (12/3/5), Mossberg Special Purpose (13/5/4).',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8caa31a9-8540-4b0f-aff1-20539462ebbd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Defensive Mastery',
  'Suitable for: Martial Artist.  When the foe takes more than 10 Wound Points from a weapon-wielding hero, the foe may spend 1 shot to Disarm the hero.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2dc225a6-98bf-493c-9b18-f289b17382f5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mantle of Rule',
  '<p>Spend 1 Chi to trigger deference from all authority figures present in the current scene. Lasts until end of adventure, or until you actively violate their trust, whichever comes first.</p>',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0d8dcb66-8816-40ab-af4f-edc6c92d3047',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Plasma Tubules',
  'Make a close combat Scroungetech attack, Damage 9. On a success, spend 1 Fortune to swap your Wound Point total with your target’s.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '35f0dec8-983f-4fd1-9521-e2ba71db6614',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Iron Gut',
  'Ingested poisons, including toxic effects of food poisoning, have no effect on you.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ca71f979-d829-4d41-970b-f5ba630a6680',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Helix Shredder',
  'Suitable for: Scroungetech.  On a successful attack, the target takes –1 penalty to Up Checks until end of fight.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9d540210-8b3b-4d51-bcff-9c849c2e673c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rippling Death',
  'Spend 1 Chi and 2 shots to gain +2 Martial Arts vs. multiple opponents until end of sequence.',
  'Sword Master',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6691280d-e31b-4944-8d76-10d2eeb48d3b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Reversion Curse',
  'Suitable for: Sorcerer, Ancient or Past Martial Artist.  Spend 1 shot; if the foe is still active at the start of the next keyframe, all Transformed Animal heroes will gain 5 Reversion Points at start of the next session. Explain these stakes to the players. Usable once per session.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cce1c589-f502-49d9-9cbe-867b13bf83d6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Emit Smokescreen',
  'Spend 1 Magic to allow any number of characters to automatically Cheese It.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5d2d9ae1-5bc5-4852-b4fb-0589235d6517',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Death Resistance II',
  'Add +3 bonus to Death Checks.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '461e6378-b7f9-428e-abcf-1232cb480a8c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shell II',
  'Spend 1 Chi and 2 shots; gain +2 Toughness until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8d57d514-8f67-4be4-ba93-17712edd6054',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flowing Strikes',
  'Once per fight, spend 1 Chi and 1 shot, choosing a specific foe. Your Martial Arts attacks against that foe cost 2 shots each until end of fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ea7d15e2-6faa-4127-97e4-85cec793b9cd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Iron Gut',
  'Add +3 to Constitution Checks to resist the effects of overindulgence in food and alcohol, and against poisons of all kinds.',
  'Redeemed Pirate',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '267dbdc9-6147-4d75-9fe0-9491e1221853',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ready Resupply',
  'When an ally gets a Way-Awful Failure on an attack, is disarmed, or fails a Reload Check, you may spend 1 shot as an interrupt: that ally may make an attack as an interrupt at a shot cost of 0 and gains +2 Damage (stackable) until the end of the fight.',
  'Full Metal Nutball',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5a2c5759-f5cc-4991-972b-11c3a158da0c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Psychic vampire',
  'Spend 1 shot as an interrupt when your attack deals 3 or more Wound Points to an enemy. Subtract 3 from the Wound Points dealt to regain a spent Genome point.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ce2f0c5c-a101-4f9f-8406-a47bbb04fde2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Disfiguring Strike',
  'On an attack with an Outcome of 4 or more, the target hero suffers a gruesome (if temporary) physical injury that leads to a complication in her melodramatic storyline. Usable once.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4014e784-f847-4788-997c-4fad1f550eb0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Way the Wind Blows',
  'Instead of a penalty under adverse conditions, you get a +2 attack bonus.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e69bae41-e2a3-4e9c-9545-4bc3082de4e9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Toxic Dart',
  'When downed, the foe may as a 0-shot interrupt make an Attack against any hero’s Defense. If successful, the Attack does no immediate damage.Ten minutes after the fight ends, the target must make a Constitution Check or take 15 Wound Points.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f0266892-a6a1-44b6-97f9-9f2d5dcb3627',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Humble Fury',
  'Add +4 to Martial Arts on the first attack you make after passing an Up Check.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dc1f7149-c99e-4fdf-9712-2ed4ffc31a5c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fear Shift',
  'When another hero takes a Mark of Death, give a boost to any ally. When another hero goes down, give a boost to any two allies.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fde505c0-db94-405e-96fe-948f8b08df7e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Extremely Strong',
  'Add +5 to all Strength Checks. This counts as Very Strong for game effects that require that to activate.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd32c016b-9a35-4467-942b-91c29764f698',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bloody But Unbowed I',
  'Add +2 bonus to Up Checks.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '67602970-ff8c-4b2d-9b47-5986511a7dac',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Finding the Tell',
  'Add +2 to attacks against characters you spoke with in the previous scene.',
  'Private Investigator',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '468f29f6-dd41-4336-9752-b6c1c0ad4e82',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tingle',
  'Spend 1 Chi to know whether anyone who wants you dead, or has designs on a feng shui site you are attuned to, or is currently within 1 km of any feng site you are attuned to. If you are attuned to more than one site, you know which one. Other than that, you only know of the possible danger.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6035531d-253e-41ba-9bc3-6abd0cf01595',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Justice Bringer',
  'Add +2 Guns vs. any target you know to be a murderer, torturer, or felony sex offender.',
  'Maverick Cop',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '527cc290-12ae-4bdd-a105-adde10bf4808',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lime in the Coconut',
  'Spend 1 Chi. Until the end of the fight, anyone taking Wound Points from a grenade you threw takes an extra 4 Wound Points.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '66170bb5-d098-429f-9a2c-be60a8cba4c4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pain Uptake Inhibitor',
  'When you take 10 or more Wound Points from an enemy attack, add a free Fortune die to your next attack.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '918d2196-3aa8-46e1-9191-51314c825a75',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning Reload III',
  'Add 3 to the results of all Reload Checks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'eb7f3e5e-f357-4b59-b2c1-d0592b9367fe',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fast Draw IV',
  'Add 5 to your Initiative result. Your first action of the sequence must use Guns.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ec6eb87b-b96f-492f-b111-937468db6c2f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pain Eater',
  'When your attack takes a foe from 0 to 1 Impairment, or from 1 to 2 Impairment, regain 3 spent Genome points. When an ally’s attack takes a foe from 0 to 1 Impairment, or from 1 to 2 Impairment, regain 1 spent Genome point.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1ddebe78-ba88-45f8-b6b9-2837e5a383ef',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mesmerizing Dart',
  'Spend 1 Chi and 1 shot. Until the next keyframe, every time you attack an opponent they lose 1 shot, regardless of whether your attack hits or misses.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e9f4c668-f940-4a07-9de6-39ee5bacaccd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Covering Fire',
  'As an interrupt when an enemy tries to stop an ally from Cheesing It, make an attack against the enemy. The ally successfully Cheeses It.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3cf14884-eb31-4496-8b38-8add8f8f4d7c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Reactive Fire',
  'As an interrupt when an enemy gets a Way-Awful Failure, spend 1 shot to attack that enemy.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1cae51cf-25ca-45fb-ae4e-681a61987357',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  '''Tis But A Scratch',
  'When for the first time in a fight you take 10 or more Wound Points, spend 1 shot as an interrupt to reduce Wound Points taken to 1.',
  'Redeemed Pirate',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '15c3c90a-5f4b-444a-a2b8-634f9307e471',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Assessment',
  'Spend 1 shot or 1 Magic to tell if any of the enemies you face are bosses, and if so, which ones.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd3b2f8c7-32e5-4c48-a9e3-5df3ab4f9eb9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Claw of the Tiger',
  'When your Martial Arts attack deals Wound Points to an opponent, roll a die; if the result is even, add the result to the Wound Points dealt.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7de3d64c-1e2e-495a-9fad-9e6d704340e6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Blow Up Real Good',
  'Take X Marks of Death to make a Scroungetech attack, Damage Value 20, against X–1 targets, who can be either in close or ranged proximity. Your attack hits every target whose Defense your attack meets or beats. If your result is less than the lowest Defense among any target, gain a retroactive +1 bonus to it.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1daed7a6-4d86-4106-8e21-d3aa5de33690',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fleet',
  'As an interrupt after Initiative results are determined, spend 1 Chi to switch your opening shot for the sequence with that of any other combatant.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '85dab0b0-c96c-48f0-b6d9-da459a5ac116',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pep Talk',
  'Spend 1 shot and make an attack against the Defense of the hero the foe last tried to hit. On a success, a number of downed mooks equal to 1 plus the Outcome recovers, and the foe spends 2 more shots. The foe can’t revive more mooks than are currently downed.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '07bbcc48-e283-4b46-870c-2a821ae88162',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Monkey See, Monkey Crouch',
  'When a hero Dodges, the foe gains +3 defense against next attack. This is not cumulative.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '52dcd814-43f5-4d41-bda4-4b17f4e3b9eb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Borderline psychopath',
  'Add +1 Attack vs. foes who disrespected you in a previous scene.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c7c6978e-c040-4d0a-ad70-9981b87761c6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Both Guns Blazing V',
  'Fire two guns simultaneously at your opponent; these must be handguns or otherwise outfitted with a pistol grip. Treat as one attack at Guns +2, with the Damage Values of both guns added together, and the opponent’s Toughness doubled.The next time you are attacked this sequence, you get a +2 Defense bonus.  Make one Reload Check for both your guns; one reload action reloads both of them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '04f3f889-70a9-40c9-8f9d-e098fdb49332',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Exorcism',
  'Spend 1 Magic or 3 shots to free a single individual of any effects caused by Sorcery or Creature Powers.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '57ef12db-d013-487b-9737-a019a1038061',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hammer Punch',
  'Your base damage with an unarmed Martial Arts attack is 9 or the current shot number, whichever is higher.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9e26b751-62d6-4f70-814b-2cfa2e6959b1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bounce',
  'Make a 5-shot Martial Arts attack at +3. If successful, opponent loses 1 shot.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '25526a37-d1a4-4293-b262-83e836f47a7d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Needling remark',
  'When exchanging barbs with a character in a non-combat scene, spend 1 Fortune. Until the end of the adventure, that character gets +1 to attack you; you get +2 to 1 attack that character.',
  'Private Investigator',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '57d96310-6dc7-49b3-9140-f20e361ef476',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tempest Shield',
  'Spend 1 Shot to generate a brief, swirling barrier of wind and lightning around themselves, deflecting ranged attacks and disorienting close opponents. 

+3 Defense until your next action.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '738704e5-6b40-44d5-ae9a-cd0fb6975b98',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Seeker Missile',
  'Make a Scroungetech attack against a mook. If successful, spend 1 Fortune to down an additional number of mooks equal to your Outcome - 13.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ef73903c-490c-4137-894a-ec12b718e0b8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hide Kinship',
  '<p>Characters normally able to identify transformed animals mistake you for an ordinary human, even when they use their most reliable tests.</p>',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6decdebc-7f54-44f7-ab41-68a4cdf575c1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Demon Punch',
  'Make close combat Creature Powers attacks against your opponent’s Defense, with a base Damage of 13 during the first sequence, 11 during the second, and 9 in subsequent sequences.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7aec561e-bf85-4f1b-afb2-476e32e2a721',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Dazed and Contused',
  'Until the next keyframe, enemies getting out of a crashed vehicle the foe at any point rammed or sideswiped take 1 point of Impairment and add 1 to all shot costs.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f046af46-8d8c-47f7-b968-0e559ad3804d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shared Bounty',
  'Spend 1 shot to remove 10 of your own Wound Points. The enemy with the highest Wound Points total also removes 10 Wound Points. You can only use this if at least one enemy has 10 Wound Points.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e2373fc9-5ce1-4754-a589-f18d8c5a6089',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ram Speed I',
  'When you ram or sideswipe a vehicle, gain +1 Crunch. +2 to your Damage Value when you hit a pedestrian.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '146058e7-4b3b-46fd-975d-153a6fe793ad',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tight roll III',
  'When a vehicle you’re driving crashes, you and all occupants gain +6 Toughness against crash damage.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e2fca4f3-99d8-4aff-83f8-59c725711cde',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wily Stupor',
  'Spend 1 Chi; until the next keyframe, add the number of servings of alcohol you’ve consumed during the fight so far to your Toughness.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4d60e69f-85cd-4a6f-ac94-43f76bc681d6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Transformation II',
  'As per Transformation I, but you can spend 1 Magic or 3 Magic to assume a new, normal- looking human form other than your default. If you spend 1, you can never assume that form in any subsequent session. If you spend 3, you can change to that form at will for the length of the series.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c12f71f5-a8c7-47d8-a1ee-9c8e284bc9bf',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Natural Order',
  'When you take Wound Points from a Guns attack, spend 2 Chi as an interrupt to ignore them. If the fight takes place outdoors, a downpour ensues, and the area undergoes the adverse condition Torrential Rain.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c74efda9-edda-463e-9ca1-e2cd4d30e267',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Screaming Steel',
  'Suitable for: Sorcerer, Supernatural Creature, Mutant.  On a successful attack against a hero fighting with a weapon, all mooks make a 0-shot cost attack on the hero as an interrupt every time the hero attacks with that weapon. This effect lasts until the end of the fight, or until the hero drops the weapon and then Rearms, whichever comes first.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b6e1d3cd-5dc4-4d02-b771-330fb137cc9d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Training Sequence I',
  'Add +4 attack vs. uber-bosses.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '873b9cfe-fa7b-4654-ae37-6945ae7b06f6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fire Strike',
  'Spend 1 Chi and make a barehanded Martial Arts attack at +2 Damage. On a success, if your opponent is wearing flammable clothing, that clothing ignites and the opponent must take 3 shots to slap the fire out or suffer 1 Wound Point every 3 shots until something is done about the fire.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '783143ee-1612-4779-a9d3-1ff0f3f0ca70',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hair-Trigger Neck Hairs',
  'Gain + 1 Defense for the first sequence of any fight your opponents start unexpectedly.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'abf9714e-bfe5-44b4-9c5d-d398e97064fb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Greed Potion',
  'Spend 1 Magic to formulate a potion which, if ingested by a featured foe or supporting character, causes him to obsessively seek a particular item of value. At the end of each subsequent scene, make a Sorcery Check against the target’s Will Resistance. The effect ends when you fail a check, or at end of session, whichever comes sooner.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '804d09ab-2674-4a9e-8c37-876580685634',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Radiation poisoning',
  'Suitable for: Scroungetech, Mutant.  Spend 3 shots and beat a hero’s Defense with a Scroungetech or Mutant Check; if the foe is still active at the end of a sequence, that hero takes 22 Damage. Explain these stakes to the players.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4697c297-f011-413f-9bc2-f3dacc44a68e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Reflect',
  'As an interrupt when hit by a Sorcery attack, spend 1 Chi and 1 shot. The Sorcerer takes the Smackdown instead of you.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e82cf504-55f4-4c15-abda-cc70acdf67b1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Throw',
  'Add +2 Martial Arts with thrown weapons.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2e9d64e6-4509-439f-b8ec-1e3d716b9cda',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Allegiance',
  'Spend 1 shot or 1 Magic to tell if a person you can see (in person) knowingly works for a faction or conspiracy. If you have heard of the faction or conspiracy, you know which one. Otherwise, you only see that the person is a player in the Chi War. Shot cost matters only if you’re seeking this story benefit in mid-fight.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1a7451cc-7bc2-4b80-96f0-812817d3486c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Kneecapper',
  'When the foe’s close attack hits with an Outcome of 3 or more, the target loses 3 Speed until end of fight. No hero can lose more than 3 Speed to any Kneecapper effect in any one fight.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ee69fa00-409c-4583-aca5-7a914cd631f1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Constrict',
  'Spend 1 Chi when you hit an opponent with a Martial Arts attack. Opponent takes 5 Wound Points whenever it attacks a target other than you. Lasts until you fail an Up Check, or end of fight, whichever comes first.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e69c36d4-8ffb-4d80-850f-5588b977343d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Radiant Grant',
  'When you give an ally a boost, roll a die. On an even result, choose a second ally to also gain the benefit of your boost.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd8c1acf4-00f9-4062-b742-b7ca421d08f9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Oxygen Sink',
  'Suitable for: Mutant.  While the foe is up, heroes take –1 penalty to Up Checks.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a98d85dc-59f9-4e14-8a06-f36d8f747c2f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Retrench',
  'Regain 7 Wound Points at the end of any sequence in which a hero Dodged.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ef071c84-71dd-4558-8503-a0a0cc0d6745',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tactical Genius',
  'Spend 1 shot; until the foe goes down, mooks gain +2 attack.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8dc9a8ba-fcfe-4c72-aa66-c94c38e5aa98',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Far Lift',
  'Cause an inanimate object to rise into the air, move horizontally, and then none-too- q gently set itself down again. Maximum vertical distance and maximum horizontal distance both equal your current Magic points in meters. Difficulty is 1 for every 5 kg the object weighs.  This takes 3 shots, if used in combat. If you’re dropping the object on an enemy, the Damage Value of the dropped object equals the Difficulty of your Sorcery Check. Your check must also exceed the target’s Defense.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6488ee55-8733-4c7e-8803-17ed48dd788e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Carnival of Carnage IV',
  'Add +2 Guns vs. mooks. Subtract 2 from the shot cost of any attack on a mook or mooks. Minimum shot cost remains 1.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '842529d8-0630-465b-b6fa-25347ed4944d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Innate Superiority',
  'Your unarmed Martial Arts Damage Value equals the Damage Value of the foe you’re hitting +1.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0108d625-6900-440d-9339-08115c761b7e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Disrupt Meridian',
  'Suitable for: Martial Artist.  As an interrupt after a successful attack, spend 6 shots. Roll a die. On an even result the number of Wound Points dealt to hero doubles. On an odd result the hero takes 0 Wound Points.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'acbff4d3-4f5c-49e0-8bef-1366db72603e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fight Finder',
  'Spend 1 Magic to know the location of the nearest group of people who want to kill you. You do not know which group. If no one wants to kill you, it must be early in the series. You get the spent Magic back.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'aad140c1-52ba-4fa8-86e1-1bec132c3290',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Exposure',
  'Spend 2 shots or 1 Magic to tell whether a person you can see is a Transformed Animal.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '59506a2c-b51e-4c9c-83dc-8cc6280c5fe9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Echoes of the past',
  'If you deal Wound Points to a Transformed Animal foe, and it goes down at any later point in the fight, it reverts to its animal form. Transformed Animal heroes present for this take 3 Reversion points.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3188fe9b-049f-4580-b87b-d543c819cdec',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Chi Flow Perception',
  'Your base damage with a punch or kick is 10, not 7.',
  'Old Master',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f6d696c1-352c-4cca-b9b6-ae8b52c05ff4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Teleread',
  'Spend 1 Genome point to know the definitive answer to a single question of 25 words or less, if that answer can be found written down anywhere in your current juncture.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9b1769f1-d91e-43a6-9048-faf461d4a414',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Act in Darkness',
  'Find and target enemies without penalty in complete darkness.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1859c6fa-27a8-44bc-9460-11435fef6283',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Slow the Tiger',
  'After a successful Martial Arts attack, spend 1 Chi and 1 shot. Target of the attack adds 1 to the shot cost of all actions with a cost of 1 or more until the next keyframe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd508b89a-0caf-43be-b4a6-44c83af2bf3c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lone Wolf',
  'Add +3 Defense if you are the only viable target for three or more named character opponents.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2592f5e5-bd23-4cca-8766-45907c67a7ea',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Indefatigable',
  'Impairment points do not decrease your Martial Arts attack value.',
  'Karate Cop',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'af019e87-b6a4-4e1b-b323-2d207dc543f1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning Reload I',
  'Add 1 to the results of all Reload Checks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5d181543-0b33-49f9-aee0-2ca7ea56415f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Poison Sac',
  'Spend 1 Chi as an interrupt after making a successful Martial Arts attack; your target takes no Wound Points. Until end of fight, each time the target is hit by an attack, its Toughness drops by 1. Opponents suffer no additional ill effect from all further hits with this schtick.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '09170b4a-aa84-4589-9569-7a781c100325',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Leap of the Tiger',
  'Spend 2 Chi as an interrupt at the end of your action or another character’s action. Your next action occurs at the beginning of the next shot.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '16d031de-f41c-4eec-8b88-42e43946d1cf',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shake It Off',
  'Remove 10 Wound Points after a successful Up Check.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '85ff03ee-9e78-40fc-9344-73e45388c8d1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hot Hot Hotspot',
  'Connect any wi-fi-capable device to the Contemporary Juncture internet from any place on the planet, from the Netherworld, or from any other juncture, including pop-ups.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '142260fd-b0aa-43a1-951a-0e4237cad4b3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Energy Drain',
  'Suitable for: Mutant, Supernatural Creature, Scroungetech.  Add +2 attack if any hero spent a Fortune point (including subtypes) since foe’s previous attack.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '77e5f4c8-2924-4eef-a5a5-321186229527',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tired Bones',
  'Make a Difficulty 7 Constitution Check whenever you take damage during a fight. Each time you fail, your Defense drops by 1, and stays that way until end of fight.',
  'Old Master',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c08f14c8-e720-41e0-825d-59cd7250a6fa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Agony Grenade',
  'A relic of the old regime, this looks like a regular grenade with a demon hand for a pin. Spend 3 shots to deal all combatants 1 Wound Point each shot until end of sequence. Spend 1 Fortune apiece to spare allies (but not yourself ).',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9662ed5d-95b7-48c7-b828-220e07e08d81',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Quicksilver Dive',
  'If you get hit while Dodging, you regain any Fortune spent on the Dodge, and your next attack action costs only 1 shot.',
  'Thief',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '87614bda-8e5f-4844-b68d-2fb41f5cf26e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Horse Stance',
  'When a named opponent misses you with a Martial Arts attack, you move up in the shot order to act on the subsequent shot.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c9b3e8cb-5e12-483f-b890-b6ead7281086',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shed Skin I',
  'Spend 3 Chi to abandon your current human form in favor of a completely new human appearance of your choice. It may match the same general type as a particular person you have in mind, but the resemblance is glancing at best. You may never return to your former appearance. The transformation itself takes 1 hour and leaves behind a filmy outer layer of discarded skin. Ew.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '623fd0e1-d6e1-412f-95bf-acefbb699540',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Both Guns Blazing II',
  'Fire two guns simultaneously at your opponent; these must be handguns or otherwise outfitted with a pistol grip. Treat as one attack at Guns -1, with the Damage Values of both guns added together, and the opponent’s Toughness doubled.  Make one Reload Check for both your guns; one reload action reloads both of them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b41bf11b-6b54-44e0-894e-87a017c60012',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Healing Petals',
  'Spend 4 shots and 1 Chi; make a Martial Arts Check. Take your Action Result and divide it any way you like between any number of characters. The characters each subtract from their Wound Point totals the share of the Action Result you have allocated to them.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e84554ae-60eb-4c3c-82a7-41da96fcebb6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Blade of Darkness',
  'Spend 2 Chi and 0 shots to create a six-inch razor-sharp blade from thin air. Its Damage Value of 14 drops by 1 at the end of each sequence. The blade dematerializes at the end of the fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5f507304-1697-47c9-9bec-9f2121b99809',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Healthy as a Horse V',
  'You get a +7 bonus to Constitution Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4ba721e7-0c07-4e92-a97a-bdb409215309',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Regeneration IV',
  'Your Wound Point total decreases by 6 at the beginning of each sequence.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a4dac6dd-ae28-4940-ba42-38fa5ecb3445',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Scroll of Spells',
  'Spend 2 Magic to gain any Sorcery schtick you don’t have, provided you have at least one schtick within that specialty, until end of session. Takes 3 shots if used in combat (6 shots if you’re 2 3/6 looking at the rulebook',
  'Sorcerer',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '91c5316b-755d-4413-8433-f6d55243b97a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Brew Antidote',
  'Spend 1 Magic to eliminate any one effect of a foe schtick that continues past the end of a fight.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '134df223-2da6-456a-a578-45dbb3a6e4a1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shell I',
  'Spend 1 Chi and 3 shots; gain +2 Toughness until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1fb78e49-3f1e-4dc1-a208-c40ee9ec85ed',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stack the Odds',
  'Spend 1 Fortune to reverse the results of any Swerve, treating the negative die as positive and vice versa. Others must share their die results with you when asked.  Explain how your planning or advance knowledge led to this 1 reversal.',
  'Gambler',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7fd4f415-1992-4da3-86f9-56f21f369831',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Acid Blast',
  'As per Chi Blast. Also: on a successful attack, spend 1 Magic to give the combat area the adverse condition Toxic Fumes until the next keyframe.  Spend a Magic point to destroy or decisively degrade a piece of unwanted evidence, beyond all forensic efforts to reconstruct it.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '565b7e9c-dd55-4bde-98ef-e05840d509f7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Quantum Bastard',
  'Suitable for: Scroungetech.  While the foe is up, all heroes take 5 Wound Points each time they roll boxcars.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '59cbef55-c119-4faf-b54f-c4042c52919a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Robust Health',
  'Add +3 to all Constitution Checks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a2cc70ca-ebe0-4d47-8464-bdf8f465b919',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Death Resistance I',
  'Add +2 bonus to Death Checks.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '59d08124-8600-40ab-a760-5830e8864644',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Blam Blam Epigram',
  'Add 1 to the shot cost of any Guns attack and make a pithy quip before or after shooting. The Damage Value of your weapon increases by 2 against a non-Impaired opponent, by 8 against an Impaired opponent.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '63f1c956-52fb-44b0-aee9-f2c6b6ac36e1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mind Control',
  'When a featured foe declares an attack, spend 4 shots as an interrupt to choose a new hero, named character, or mook as target for the attack.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9bf3ae1d-2c15-46fe-bc6b-f45e49fb2225',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Helix Ripper',
  'The defeat of the Architects left these massive rifles made of demon bone lying around for just anyone to pick up.  Make a +2 ranged Scroungetech attack against a mook or mooks. For each mook you down, you regain a spent Fortune point and take 2 Wound Points.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5edc17e8-5437-4265-a7cf-b1d5fa13d413',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Improvised Weapon Mastery',
  'Gain +1 Martial Arts when fighting with an improvised weapon found at the scene. After 3 successful attacks, you lose the bonus—unless you describe yourself picking up and using a different improvised weapon (shot cost 1).',
  'Everyday Hero',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5f897dff-93f0-4b07-8dc2-d71d19a62fae',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Thunder Charge',
  'Spend 4 Shots to rush forward with a spear thrust, leaving a trail of crackling energy that shocks nearby enemies, causing all nearby enemies to spend 2 Shots.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '33088f61-e8c3-40aa-bb3b-f235e002ac9f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Healthy as a Horse III',
  'You get a +5 bonus to Constitution Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ef179308-c126-4825-b73c-863143569d8b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Time-Tested Tech IV',
  'As an interrupt when an enemy fails a Reload roll, spend 1 shot to make a +5 Guns attack with a bow and arrow against that enemy.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c162e45b-8699-43c0-abd6-79cf0b417b60',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Backslash',
  'When you hit a named foe, spend 1 Chi as an interrupt and roll a die. Odd: drop 1 mook. Even: drop 2 mooks.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '49a232c3-5d6d-4fa4-b8fd-4641fc1f63e2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hold Them at Bay',
  'Spent 1 shot and 1 Chi. All mooks spend 3 shots.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2bf8fb88-d5c4-40c9-a069-c72cac3e87a7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Trumpet',
  'Spend X Chi to send a psychic distress call to all transformed animals within 10X km. They know where you are and that you are in trouble, but nothing else. How they respond is up to them.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd008eb3b-a8a6-49d3-99ea-b5ba32d77685',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Conditional Escalation',
  'Add +2 to Creature Powers if at least one of your allies has 25 or more Wound Points. +3 if at least one of them is down.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5d056484-c1f9-42d2-bf99-59bd1be7f22f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tight roll I',
  'When a vehicle you’re driving crashes, you and all occupants gain +2 Toughness against crash damage.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fd19c5ad-befa-48ed-8ebc-58e5205a6dad',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Scattering Fire',
  'When you hit one or more mooks with a Guns attack, all other mooks in the fight must spend 2 shots.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd2562335-615c-43cf-a6e0-aba057329269',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Elevated Senses',
  'Spend 1 Magic to gain (your choice) +3 to Notice, or a Notice value of 12, until end of scene.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd9cbff1e-b6bc-499b-946a-29861af9cc3f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Nuh-uh',
  'As an interrupt when a hero regains any number of spent Fortune (including subtypes), spend 3 shots to attack that hero.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '612897b7-346f-41dc-a890-90e72c48a3d1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stubborn',
  'Spend 1 Chi and 1 shot when you fail a check; make the check again.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8a9f5ea8-0477-48af-b12f-f928b12cfff8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heal Wounds',
  'Spend 1 Magic to reduce the Wound Points of any character by the result of your q Sorcery Check. In combat, this takes you 4 shots.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '81c51568-19a7-4986-9b41-f21fd007e02b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tricksy',
  'As an interrupt when you are targeted for attack, spend 1 Chi and designate a different hero as target. Be prepared to explain how you’re doing this.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a1a0b393-0d99-4cbc-b607-08f69b9ba78e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Yin to Yang',
  'Spend 1 Magic as an interrupt when you take Wound Points. Your next successful attack deals no fewer than this number of Wound Points.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd5e49ca9-1a3c-4c2a-8f5e-1f07342052a4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Look out, Kid!',
  'Roll a die when you are attacked while benefiting from a Defense boost. On an even result the boost continues until end of next shot.',
  'Scrappy Kid',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '08242787-53ef-4b36-a82a-160ad9ea8d9e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Medkit',
  'Spend 3 shots to remove 7 Wound Points from a boss or featured foe.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd278f266-17c2-4bb9-9e9f-b3cbd21f2a73',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Interceptor Drone',
  'As an interrupt when an ally is hit by a ranged attack, spend 1 shot to grant that ally +5 Toughness. Bonus applies to the damage from this hit, as well as any other subsequent attacks this shot.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cdd7fcf7-be06-437b-bae9-e8eba710ecd4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heroic Bloodshed',
  'In the climactic fight of an adventure, any attack that deals you more than 4 Wound Points deals an additional 3 Wound Points.',
  'The Killer',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '72016878-5338-46f0-9cfd-747909db6a4b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shadowfist',
  'On a successful Martial Arts attack, ignore normal damage determination. Instead, both you and your opponent roll a Swerve and add 35 (or 50 for Big Bruisers and bosses) to it, adopting the resulting number as your current Wound Points total. Neither you or your opponent can use any other effect to reduce Wound Points before performing an Up Check.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fd26d92f-775a-4180-b057-f9524ebbe481',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Soul of the Sniper',
  'If you are the first combatant to attack in a fight, you gain +2 Guns on that attack. You and all of your allies gain +1 Attack for the rest of the first sequence.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9771cfbe-5477-4277-af09-ceb5814f2a84',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Strong as an Ox III',
  'You get +5 to all Strength Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dabb7e9d-c675-4095-a2b7-0b053c2867a1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Spasmodic Leap',
  'If a Guns attack misses you on any odd-numbered shot, regain a Chi point.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6f5a5ae4-ca5e-4b28-a109-6e621af73533',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Very Fast',
  'Spend 2 Genome points. Until end of sequence, the shot costs of your actions decrease by 1, with a minimum of 1 per action. You can move up to 30 m per sequence.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9318ccc5-6c20-42ac-b44d-b8a6b2f29267',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Banishment',
  'Spend 3 Magic and 3 shots; on a Sorcery success against a supernatural creature’s Defense, it Cheeses It. On a failure, you regain the Magic points.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'aec746aa-c7a2-47ae-a883-1c72f21e2a16',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Thwart the Dragon',
  'When a nearby ally takes attack damage, interrupt and pay 2 shots to remove all Wound Points the ally gained in the attack. Costs Chi equal to the number of times you have used Thwart the Dragon this fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd10f99a2-1cb8-4eaf-8e7c-21766fb64ddc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hands Without Shadow',
  'You get +X Martial Arts vs. opponents whose Defense values, bonuses included, exceed your current Defense. X is equal to the difference between Defense values.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9837ee42-1948-4de9-aa7a-de9c33100667',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rock Hard',
  'Suitable for: Martial Artist, Supernatural Creature, Cyborg.  Heroes making successful unarmed attacks against this foe take 2 Wound Points per attack.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b9761905-4b81-414c-8236-94c92c7da4da',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shared Sight',
  'Eat a small sample of skin, hair, or nail from a person or other intelligent being. You see what the target is seeing for the next five minutes. You may renew the effect for five minutes at a time at a cost of 1 Genome point per renewal.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '846ef752-66f4-4339-ad5a-85380c39bf7e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Turnabout',
  'When the foe is up, this and all other foes lose 5 Wound Points on every hero’s successful Up Check.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '79064816-d971-4633-b665-7124fe92116d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sudden Jab',
  'Add +3 to Initiative, provided your first action in the sequence is a Martial Arts attack.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f85fb268-372a-43d9-9bc2-126f3e548e8b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Warning',
  'Spend 1 Magic as you draw a chalk outline on a suitable surface, covering an area of up to 450 square meters (about the size of a convenience store). For the rest of the adventure, you immediately know if anyone crosses the line.  You can direct a Chi Blast (if you have that schtick) at any one target crossing the line, no matter how far away you are from it in space or time.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bdebe6f5-d639-49c0-8284-a8139aca378c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Traditional Healing only',
  'The Medicine skill only heals you if the practitioner trained in the Ancient Juncture.',
  'Ghost',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dd37aa1e-e80a-4814-b7fd-d745d3f51676',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Foggy Tendril',
  'As per Chi Blast. Also: on a successful attack, spend 1 Magic to give the combat area the adverse condition Obscured Vision until the next keyframe.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5f306ce5-fecd-4000-8b48-15ae3f80a626',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Not So Fast',
  'When a hero Cheeses It, this foe may spend 3 shots as an interrupt to deal that hero 14 Damage. This does not expend the bad guys’ one chance to stop the hero from Cheesing It.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9e2114c5-3389-409e-9060-77e11416a0fa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Perseverance',
  'Spend 1 Chi. Select a foe. Each time you miss this foe with a Martial Arts attack, gain a +1 cumulative bonus to Martial Arts attacks against it until end of fight.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ec44450b-5360-460f-8cf9-f4a3b95f307d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shell III',
  'Spend 1 Chi or 1 shot; gain +2 Toughness until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6de627ea-06de-47d0-b999-282c3e8dd4e1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Dim Mak',
  'Any time after the second sequence, spend 3 Chi and make a Martial Arts punch attack against a featured foe. If successful, ignore normal Damage determination; the foe’s Wound Point total is now 34. If unsuccessful, regain 2 Chi. This has no effect on bosses.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'eb34c231-9bc0-4045-9551-cda9d31e62ba',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mutant Punch',
  'Make hand-to-hand attacks using your Mutant Attack Value.',
  'Gene Freak',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c4009219-9120-4134-b1dc-18fbbb98aeba',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Whirl of Fury',
  'Spend 1 Chi as you make a Martial Arts nunchaku attack. If you hit, this and all of your nunchaku attacks for the rest of the fight have a Damage Value of 14.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '232fd22b-a279-4b6c-918d-1ceef0adfac7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'System Malfunction',
  'Subtract –2 Toughness when making Up or Death Checks.',
  'Cyborg',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c1846f3b-52eb-46eb-9168-406ab1b4a3c2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Elephant Walk',
  'Add +1 Martial Arts until end of sequence when you roll a lower Initiative than any other hero.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '093e4bba-23a0-45cc-ab9f-df93fe2abd68',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Monkey King',
  'Once per sequence, make an attack with staff or spear at a shot cost of 2.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b2aaf5e1-7ac5-4ed4-ac2e-5a67a7c53018',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Regeneration I',
  'Your Wound Point total decreases by 2 at the beginning of each sequence.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'df239ddb-0cd1-4d12-bdf7-2a39efcd69e8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Slow but Steady',
  'Add +2 to attacks during a sequence’s final 3 shots.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c2d3ca0c-1eb1-4930-bbf7-9ecb90787cb8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Remote Manipulation',
  'Perform manual tasks involving distant objects or devices. Difficulty of the Sorcery Check equals your distance in meters from the object, which you must be able to see.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2f86da9f-6518-4f18-b03d-81f440bdb35a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Demon Spoor Extract',
  'Spend 1 Magic to cancel a foe schtick effect that directly bolsters a foe and is otherwise due to expire at the end of the sequence, keyframe, or fight.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3682ada5-34eb-47ba-b921-c661c9f64c24',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Laying Rubber',
  'Pay 1 Fortune as an interrupt when a passenger in a vehicle you’re driving is targeted for attack. All passengers in your vehicle gain +1 Defense until the next keyframe.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '777f2e19-f571-4d4c-883a-9bc967ac3e86',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Unsplode',
  'Spend 1 Genome point to completely suppress any explosion whose epicenter you can see in person. In combat, is a 1-shot interrupt, when you see that an explosion is about to occur.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '825ac02b-b63c-4bc2-a712-7d312d8d032a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Quantum Manipulator',
  'Spend 1 Fortune and 3 of a willing ally’s shots to make an attack as an interrupt. Downed allies can’t give you their shots.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8a994aee-e366-4f3e-973f-30b4b215b3bf',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Oh No You Don''t',
  'As an interrupt after your vehicle takes Chase Points from an enemy narrowing or closing its gap with you, spend 1 Fortune and 1 shot to reduce your vehicle’s total Chase Points by 5.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c57553b8-19df-48f3-a83b-268a5aaf619b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Empathic Rage',
  'After another hero receives a Mark of Death, your next attack check gets a free Fortune die.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '453f5f22-1259-4539-a706-cdfeb2a984da',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tongue Grab',
  'Suitable for: Supernatural Creature, Mutant. Spend 1 shot; the foe draws target hero from ranged distance to close combat distance.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b162fb60-289b-4132-af92-72c8b38f611c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Zigzag',
  'Spend 1 Chi to treat all mook hits against you as misses until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '28cab733-3823-4526-9d95-7e9e6b157350',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Altruistic Switcheroo',
  'As an interrupt when you or an ally is hit by an attack, spend 2 shots to choose either yourself or another willing ally to take the hit instead. Use the new recipient’s Toughness to determine how many Wound Points get dished out.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3f2e18de-b663-42a7-9692-e7d497254404',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Probability Wave',
  'When you attack and miss, you may spend 1 shot to give an ally a boost.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '83e628d2-e885-4f9b-bb8c-886b62179b97',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Surprise',
  'Add +2 to Martial Arts vs. opponents who have yet to attack during the current sequence.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7ccde0b8-1885-4ec0-b0e1-a6cdec45d235',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stalky Eyes',
  'Add +2 Defense before your first shot in a sequence.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ccb178c5-3b57-4dd5-b1f4-17644734718d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tight roll II',
  'When a vehicle you’re driving crashes, you and all occupants gain +4 Toughness against crash damage.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '645b3ec6-de29-4dfd-9b36-3c05efc9348f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Conditional Escalation',
  'You gain +2 to Creature Powers if at least one of your allies has accrued 25 or more Wound Points, or +3 to Creature Powers if any of them are down.',
  'Supernatural Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '715e47d7-28b3-4615-be07-d604ef8b7b40',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Click Click Toss I',
  'When you fail a Reload Check, spend 1 shot as an interrupt to toss your emptied gun ineffectually toward your enemy. Add +5 to your next Attack Check.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f534fb1d-7640-4563-9927-e3ec67fa3511',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pathogen',
  'As per Chi Blast. Also: on a successful attack, spend 1 Magic. For the remainder of the adventure, Wound Points dealt by the attack can only be removed by the Sorcery Heal schtick.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8c0dad7c-4be4-4efd-ae07-5f4294391e52',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Override Will',
  'Spend 1 Magic and make a Sorcery Check against the Will Resistance of a GMC you can see in person, and is in a relaxed state of mind. On a success, the target executes, to the best of his ability, a single instruction of 25 words or less. +3 to the target’s Will Resistance for an instruction that clearly threatens his interests or self-image. +8 for an instruction that violates his safety or that of others.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd33fb17c-fc08-4fe4-82ab-82d5c646f6c4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Push',
  'Make a 3-shot ranged attack, Damage Value 11, using your Mutant attack value. If you deliver a Smackdown, the target flies X meters through the air directly away from you, where X = the number of Wound Points you dish out.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '34982dc5-48f6-4a05-ae84-f95c7e462561',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Molecular Disturber',
  'Spend 1 Fortune as an interrupt when targeted by a Guns attack. Gain +3 Defense. If the attack misses, roll a Swerve. If the result is negative, pick an ally to be hit by the attack, with an Outcome of 2.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '664e1dc7-509c-447b-acfb-2a1e0ddbe447',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Against All Warlords!',
  'Add +2 Guns vs. Bosses. if the boss succeeds at an Up Check, you can force the GM to reroll the Up check. Up or down, use the second result.',
  'Highway Ronin',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4970b02f-7e2a-4d60-a4d5-27db773bdbaf',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Copy Cat',
  'After missing a Dodging hero, the foe gains +2 Defense until the next keyframe.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '75ef111f-aa53-4e4b-92bc-79dd0ee293aa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Utility Belt',
  'After spending Fortune on a boost, roll a die. On an even result, you get the Fortune back.',
  'Masked Avenger',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a2bbcfd2-1e79-4489-8d95-b4027d425aa6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Web',
  'If an enemy or supporting character tries to Cheese It, spend 1 Chi to make an attack against that opponent as an interrupt.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '64cdbf0f-a84f-4903-84a5-fe4274c36ca4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Inhuman physiology',
  'The Medicine skill works to heal you only if the doctor using it was trained in the Ancient Juncture or Netherworld.',
  'Supernatural Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e08ada14-2455-41f2-a888-1061c07f2c10',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Go Cartilaginous',
  'You can squeeze through an opening as small as 75 sq cm.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd861a558-1711-42a1-bc02-1c1cf862aca0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Four-Six Stance',
  'You may make Martial Arts attacks at a shot cost of 2 against any characters who made Martial Arts attacks against you during the current sequence.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '771e942c-3c09-4d3c-80ac-49f1faaa0d8d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Catlike Tread',
  'When you give an ally a Defense boost, you also gain the benefit of the boost.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd565909a-b21f-4d47-8b5c-c655c957ce5f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bite of the Dragon',
  'Pay 1 Chi to add 2 to the Damage of your Martial Arts attacks until the next keyframe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1899c1cb-b27b-4c92-9c19-9bf08e4b682c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bend Fate',
  'As an interrupt when an enemy makes an Attack or Task Check, spend 3 shots and 1 Magic to add extra negative die to the result.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0ceba643-1939-4e6f-9c71-6ae61e46948d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Implant Suggestion',
  'Suitable for: Sorcerer, Scroungetech, Supernatural Creature.  Spend 1 shot; if the foe is still active at the start of the next keyframe, target hero takes an action against his will, in favor of the foe’s faction or interests, in a later scene. Explain these stakes to the players. Usable once per adventure.  When the implanted suggestion activates, the hero may make Difficulty 13 Will Check to suppress the impulse. Success postpones the effect until a future scene. The hero succumbs only once.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ad4b2e91-ded2-43a3-bb8f-1432517886f8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Memory Drain',
  'After damaging an enemy with any close combat Creature Powers attack, spend 1 Magic. You can access the enemy’s recollections until end of session.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f90948ea-e89b-4344-81a3-65e51a416deb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fender Blender',
  'Suitable for: Gene Freak, Supernatural Creature.  If a foe is hit as a pedestrian during a chase, the foe takes no Wound Points. The Wound Points the foe would ordinarily take are instead added to the Driver’s Chase Point total, and count as a ram or sideswipe. Unlike most foe schticks, keep this one a secret until first used.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '50a1ec63-6ef7-482d-abb2-649eeff1d6a9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Superior Evasion',
  'On a failed attack against an enemy with a higher Defense than yours, spend 1 shot. Until the next keyframe, your Defense equals the enemy’s Defense +1.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2e9e6a08-bf46-4fea-a956-6065bafbee4c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Joint Cased',
  'Add +2 Martial Arts if the current fight takes place in a location you have ever covertly entered using Intrusion, including at the beginning of this fight.',
  'Ninja',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4fcaf9bc-7105-44f5-840f-fd0fc50e876c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Both Guns Blazing I',
  'Fire two guns simultaneously at your opponent; these must be handguns or otherwise outfitted with a pistol grip. Treat as one attack at Guns -2, with the Damage Values of both guns added together, and the opponent’s Toughness doubled.  Make one Reload Check for both your guns; one reload action reloads both of them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a6c9ef6f-4366-4421-9ea5-32d41e4bc006',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Silver Lining',
  'Spend 1 Genome point; until the next keyframe, all allies within close combat range of you heal 3 Wound Points each time you take any number of Wound Points.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '36907fcf-1ba9-4e16-b509-0cf4c3b5be7a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Crosshairs',
  'Your attacks against the quarry gain a +2 bonus.',
  'Bounty Hunter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5e99fec3-333e-4c4e-ae9e-45d823f7d820',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hot Metal',
  'Suitable for: Sorcerer, Supernatural Creature, Mutant.  On a successful hit, a hero carrying a weapon must drop that weapon, or suffer a –2 attack penalty until the next keyframe. If the hero drops the weapon and then Rearms, the penalty goes away.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cc29619b-895a-4903-a141-2f82af8a686e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Claw of the Dragon',
  'Spend 1 Chi and 1 shot. Until the end of the fight, the minimum Wound Points you inflict on a successful attack equals 5.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9ad648ac-dbad-44e8-b554-51ffef871df5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Strong as an Ox V',
  'You get +7 to all Strength Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5e790b18-03c0-4593-9015-c56e5c25d678',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Breath of the Dragon',
  'Pay 1 Chi as an interrupt after you roll your Swerve (including rerolls of any 6s) on a Martial Arts attack; ignore the positive die, treating it as a 5.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fde6db6f-2414-4349-b9ca-b65023183b9f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'House Proud',
  'Add +X bonus to all skill checks in story scenes. X is equal to the number of feng shui sites you are attuned to.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ff2416bd-cf9e-4a04-bc71-2814950c3420',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Love Potion',
  'Spend 1 Magic to formulate a potion which, if ingested by a featured foe or supporting character, causes him to fall head over heels in love with another character specified by the sorcerer at time of formulation. If attraction to the object of affection contradicts the ingesting character’s orientation, the pull remains powerful but platonic. At the end of each subsequent scene, make a Sorcery Check against the target’s Will Resistance. The effect ends when you fail a check, or at end of session, whichever comes sooner.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bf96bcca-eb63-4c8e-8c4b-7f4fb5598c78',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Blooded Blade',
  'You have +1 bonus to sword damage for each mook you drop. The bonus is reduced by half (round up) each time you hit a named foe and lasts until the end of the fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'be0a2f3b-2839-4ac1-83bf-17e305ff5776',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Quick Study',
  'Spend 1 Chi to gain a schtick possessed by a PC whose player is absent. When using this schtick, you can spend your Chi points in place of any other Fortune subtype. Each time you use a Sorcery or Creature Powers schtick gained from Quick Study that requires a check or expenditure, you gain 1 Reversion Point.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f29d3b94-9ffc-4a08-9541-10e0b89a7436',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Gene Link',
  'Spend 1 Genome point; until the next keyframe, all allies within close combat range of you gain +1 to attacks.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4e6328fb-533c-4ed8-ba47-a2cda5720e1d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Counterslam I',
  'Opposing vehicles take +3 Chase Points from Bumps.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f4f949c6-ec7b-4297-b21f-eceea5cacfa5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Herd Instinct',
  'Spend 1 Chi to grant +1 Toughness to all currently close allies until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd0d0b16a-11b6-4a0c-9248-cd80e4733b43',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Big Luck',
  'Spend 1 Magic to gain +3 to Fortune Checks until the end of the next scene in which you make a Fortune Check. (Or end of session, if that comes sooner.)',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '446b5c50-dcf3-4fae-a563-3d090baed660',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Accidental Awesome',
  'After you fail an Attack Check with an improvised weapon, add a free Fortune die to your next check or Dodge.',
  'Everyday Hero',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '59c0007d-e71d-43ea-a6f2-d26c6ceda8fb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'A Ride is a Ride',
  'Ignore Unfamiliar Vehicle penalties.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1ad97046-0ec5-43a1-bcb0-49f76d5d04df',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Inured to Weirdness',
  'When a Sorcery, Creature, or Scroungetech attack misses you, regain a spent Magic point.',
  'Magic Cop',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '850719bf-21f7-4191-86fe-3df8a4a00f71',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flow Restoration',
  'Spend 1 shot; touch a subject who is unable to act due to the effect of the Point Blockage fu power. Subject is released from effect and takes an action during the following shot. Subject gets +2 to next check.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '48157bbd-b958-42eb-be1b-6636fb962713',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Drunken Stance',
  'You have +2 Martial Arts on odd-numbered shots and –1 Martial Arts on even-numbered shots. If you hold an action to act on an odd-numbered shot, pay 1 Chi.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bf12e017-37b4-4189-aa25-d6a395920f29',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Who Got Hit?',
  'At the end of a fight, remove any number of Marks of Death from your client, applying them instead to yourself.',
  'Bodyguard',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '369822c5-aa28-4356-96be-f7a3a6a3d802',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Like the Cavalry',
  'If you were not with the other PCs when they arrived at the scene of a fight, you can show up in mid-fight, during or after sequence 1, shot 4. You reveal yourself anywhere in the fight location, without having to explain how you got there.',
  'Drifter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5b075f78-63a2-4eb1-8bfc-f7c06dfb82bd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pincer I',
  'On a successful bare-handed Martial Arts attack, you deal 11 damage and shot cost of target’s next attack increases by 1. Latter effect not cumulative with previous Pincer attacks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e5c02064-722b-417b-8506-8e7811aaf0ba',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Trample',
  'As an interrupt after hitting with an unarmed Martial Arts attack, spend X Chi to add 3 times X to your Damage Value.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3efa1c3b-f00a-4fb7-92e0-7741723e13b3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Carnival of Carnage I',
  'Add +1 Guns vs. mooks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c47bee6d-9460-47dc-8f07-e88ee226fb13',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Disintegration',
  'As per Chi Blast. Also: on a successful attack, spend 2 Magic to utterly destroy a weapon of your choice carried by the target. You can’t choose a signature weapon.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'abab9593-6afa-456c-929a-fabfacb83d64',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rise in Slow Motion',
  'Immediately before the first attack you make after passing an Up Check, reduce your Wound Point total by your Toughness.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1f0345c5-b52e-4303-a458-17cc98f9c10f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Distraction',
  'Describe a distracting non- lethal assault against your target. Instead of damage, on a successful Martial Arts attack, the target suffers 3 Impairment for a number of shots equal to your Outcome. You can’t further distract an already distracted opponent.',
  'Scrappy Kid',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '735c0a39-f307-410d-a95e-b6c5c0cb01a6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Quid to Quo',
  'When you receive a boost from an ally, roll a die. On an even result, the ally also gains the benefit of the boost.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e949d60e-5762-4899-be8e-dfaa2274870b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Titanium Claws',
  'Spend 1 shot as an interrupt after dealing Wound Points to an enemy. Wound Points dealt increase by 5.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f1d699d6-96cb-4e5a-b289-0b64e768dea6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cortisol Field Generator',
  'Spend 3 shots; until end of fight, any featured foe reaching 25 or more Wound Points Cheeses It.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a6b61e17-dffd-443b-9653-d1fd5c01f3f7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Slowing Strike',
  'Spend 1 Chi as an interrupt after making a successful Martial Arts attack. Until the next keyframe, opponent adds 1 to the shot cost of all attacks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6afd4a0c-7884-41c8-a111-8aa6f6f23c5a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Slipstrike',
  'Suitable for: Martial Artist.  When this foe’s attack against a hero is successful but deals less than 5 Wound Points to that hero, the hero is Disarmed.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '992934d0-8618-4c00-8875-0a8f2614ab82',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'High Gear',
  'After Initiative is determined, if the foe’s Initiative is less than that of the first hero Driver to act, the foe''s Initiative equals that hero’s Initiative –1.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6e0ee5ae-571e-4c46-aff4-d77ecc5c59bc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Armor plated',
  'Add 2 to the Frame of the vehicle the foe starts the chase in.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2dcab342-0829-4e51-8393-7fe727434d87',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning Speed',
  'Pay 3 Fortune; until the next keyframe, the shot cost of all your Driving actions decreases by 1, with a minimum cost of 1.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '28d79421-72c7-4db7-a8c0-5638eb7d0078',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Air of Mystery',
  'Add +2 Defense against Sorcery attacks.',
  'Drifter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f7b17195-ff47-4731-9e8e-6c82e5aff14f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fortune of the Fox',
  'Treat all Fortune die results of 3 or less as 4s.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '777b9357-a9e2-4f96-ba95-642d6baa24ab',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Slow Burn',
  'If your Initiative result is less than 10, add a free Fortune die to the first check you make this sequence.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e04978bf-fcbc-4a2a-9929-bbffead92518',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Nutball Luck',
  'Spend 1 Fortune and 0 shots to gain +2 Defense vs. Guns attacks and +3 Toughness vs. explosion and debris damage until end of sequence.',
  'Full Metal Nutball',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b222e2d1-75f9-456e-92ea-162a3d43b7fb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hold on Tight II',
  '+3 to Chase Points dealt an enemy vehicle when you close or narrow the gap with it.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dcb962ef-efa0-4c5e-9243-5bda4d5e2739',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Floor It III',
  '+3 Handling when an opponent narrows the gap with you.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd25a52b5-8d06-4031-9144-9374f17d20bb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hovering presence',
  'You make boosts with a shot cost of 2.',
  'Ghost',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e2f5d079-83b1-437d-8ba0-caaf9c82a615',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'False Memory',
  'Spend 1 Magic and make a Sorcery Check against the Will Resistance of a GMC you are engaged in conversation with, and regards you in a positive or neutral light. In about a hundred words or less, describe an experience the target is supposed to have had, but did not. On a success, the subject believes that this happened to her. +3 to the subject’s Will Resistance if the incident strains credulity, but not the subject’s self- image or sense of reality. +8 if the incident does contravene the subject’s self-image or sense of reality.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f9ba4ccb-f981-4859-8fc7-35176fc26f12',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Luck of the Monkey',
  'Regain a spent Chi point after any Way-Awful Failure.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '618fce49-c8ca-467a-8146-f88d3af5ef36',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ice Blast',
  'As per Chi Blast. Also, on a successful attack, spend 1 Magic, your target must spend 3 shots freeing himself from an encasing layer of ice. Targets with Strength Checks above 7 spend only 1 shot.  Also useful for making ice cubes, freezing or chilling food, making water solid enough to walk on, and cooling the temperature in a hot room.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c0e6899d-7aed-406e-a9e0-ca24a7b48afb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wild Grenade',
  'When you miss with a grenade, spend 1 Fortune. Characters between you and your target do not make Fortune rolls to avoid it. Instead, you and a nearby character of your choice (other than the target) take 20 Damage from flying debris.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9de15319-f4e6-444c-bf6d-3eb24dfb2783',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Precognitive rescue',
  'When one or more characters take Wound Points from a source of damage other than an attack or explosion, spend 1 Genome point to reduce Wound Points dealt to 0.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a86d4ef1-ab59-49d6-8d20-cbfa5068083e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Smokin''!',
  'When you hit multiple opponents with a ranged attack, regain 1 spent Fortune.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '71a8bf07-1b47-4338-93ff-cbec71371a59',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Fox''s Retreat',
  'As an interrupt when attacked, spend 1 Chi. Until the next keyframe, Dodges increase your Defense by 4.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5d929958-9b3e-4dc6-933d-77682422f43e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stasis Field',
  'Suitable for: Scroungetech.  On a successful attack with an Outcome of 3 or more, +1 to the Reload value of all guns hero carries.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3930f716-2f34-44e7-9818-b22b0bf24518',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Adrenal Boy-Howdy',
  'Subdermal adrenaline injectors give your nervous system a kick in the pants in crisis situations. If you are Impaired, you make attacks at a shot cost of 2.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2796ded1-8623-4472-ac74-584e64882fc6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bellow',
  'Spend 1 Chi and 2 shots. You and a target make Will Checks. If you succeed and your target fails, target takes 1 Impairment Point until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9a78e241-4856-455c-8cb5-33fb6a61f52f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Elusive',
  'As an interrupt when you are hit by an attack, spend 1 Chi to force the reroll of its Swerve.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b1ec9143-ed9a-4078-8d09-d88c8eed45a4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flight',
  'Fly through the air, moving up to 5 m per shot.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '23673746-175f-464c-a763-8dc016e08ec6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Counterslam',
  'If the foe’s vehicle’s higher Frame gives an opposing vehicle a Bump value, that value increases by 3.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '63946769-2450-4140-9e83-e27382712a76',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Field Triage',
  'During a fight, spend 1 Chi and 1 shot to remove a point of Impairment from another nearby character, or 1 Chi and 3 shots to remove it from 1 yourself.',
  'Ex Special Forces',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f0cb796d-5c92-46dd-8b7d-efa8c3de89b8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mach Schnell!',
  'Add +3 to mook Initiative while this foe is up.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '66efcd00-8f9d-47c1-be59-a220bb9907ec',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Buzzsaw Hand',
  'As an interrupt after a successful close- combat attack fails to do more than 4 Wound Points to an opponent, roll a die. On an even result, target of your attack takes 10 Wound Points. On an odd result, you take 5 Wound Points.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f511f2e3-d1c6-4a98-b856-cb1beefab0b8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Inevitable Comeback',
  'After you fail a Death Check, spend 3 Magic to return to life with 5 Wound Points. You must give your fellow heroes time to think you’re definitely, absolutely dead this time.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e72c8d50-952f-4296-88f0-776790e3d6e3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Don''t Turn Your Back',
  'Add +2 to Attack if the foe has not been attacked since it last attacked.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0d04db78-bffd-4284-a372-15974addef44',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ouch!',
  'When you miss with an unarmed attack, you take X Wound Points, where X equals the absolute value of your Swerve. Your next Martial Arts attack this fight gets a +X bonus. If successful, heal X Wound Points. This schtick is always active.',
  'Karate Cop',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cefd0909-9505-4c24-9e88-b6c222b4b0fd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Teleport',
  'This foe can move from ranged to close distance long enough to make close attack, then instantaneously back to ranged distance.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd15bf8a9-b813-4724-aba5-0b699a9134a0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wrench the Wheel',
  '–3 to Chase Points dealt to the foe’s vehicle in any ram or sideswipe.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '019fef85-2251-47d8-8604-32a2659cfdda',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rally the Shattered',
  'Spend 1 Chi and 1 shot as an interrupt when an ally takes an Impairment point. Until end of sequence, the ally treats Impairment as a bonus instead of a penalty.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cb876b45-44b7-4106-a4c2-7b7bd03076b2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Force Blade',
  'Make close Scroungetech attacks with a Damage Value of 10. Add +5 Damage vs. targets with Toughness 8 or higher.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '89a00a63-5701-40b1-bb6e-30018ef8e9aa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mimicry',
  'After damaging an enemy with any close combat Creature Powers attack, spend 1 Magic. You can perfectly imitate this enemy’s voice until end of session.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b025c434-60af-4878-8f9b-971961642f46',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Swashbuckling',
  'After performing a stunt that has you swinging on a rope or otherwise evoking classic pirate action, gain +2 to attacks until end of sequence.',
  'Redeemed Pirate',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0cff0182-6caa-4f98-b33f-6109d5d7ae1d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Harvest Chi',
  'After a successful attack against a named foe, you may subtract 3 from its Outcome to regain a spent Magic point.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f2652390-dec2-4af4-9c62-c83ea7ba09e9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Knuckle Dependent',
  'Subtract –2 Damage from Martial Arts attacks you make with weapons.',
  'Transformed Crab',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '688bf044-c422-4fea-8929-39e23b0be6e1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shock Wave',
  'All heroes in the path of the shock wave must make a Defense roll against the Foe''s main Attack Value. Anyone who fails loses 3 shots.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '67b01d7a-ea74-4449-a783-455122fbad1b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Nanoportal',
  'Spend 1 Genome point and spend 3 shots as an interrupt when an enemy targets an ally with a ranged attack. Pick any combatant as the new target for the attack.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7b1da47f-e27f-4a72-a7c0-7fb38c81e59c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning response',
  'When you are hit by an attack during a shot higher than your first shot, as determined by your original Initiative roll, spend 0 shots as an interrupt to launch an attack against any foe. Subsequent successful attacks against you also trigger this schtick, provided they occur before your originally determined first shot.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4f59f894-c5cd-4e17-b360-0a63716a2509',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Leveling Strike',
  'After a successful attack, target hero is at –1 Attack vs. mooks while the foe remains active. This penalty is not cumulative on multiple hits.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b1b7adf8-32c7-4a00-bdd6-cb25103880ca',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lucky You',
  'When you run out of Fortune, roll a die. On a 1 or 2, regain all your spent Fortune.',
  'Everyday Hero',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f82d6bda-7076-4e31-b70f-9d13248bd6d8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Don''t Mess With Clint',
  'If you are the only PC in a fight, spend 1 Fortune and 1 shot to put down a mook, no check required.',
  'Drifter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '15f2a614-f4f7-444d-9045-9497a27e0ebe',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Skulky',
  'When you take Wound Points from an attack, your Defense increases by 1. This bonus stacks for each consecutive attack dealing Wound Points to you, but drops to 0 the first time an attack on you fails.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '714fb156-b726-4d21-89e6-9ccad3ee5f08',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rehearsed Getaway',
  '–3 to Chase Points dealt to the foe’s vehicle when a hero narrows the gap with it.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd0103af2-430e-4a10-beec-1a6b09c65912',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Floor It I',
  '+1 Handling when an opponent narrows the gap with you.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a09b6301-95bb-457d-abf2-0d184416c113',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Supergun',
  'Suitable for: Guns character.  If the foe brings a hero to 35 or more Wound Points, the hero gains an additional Mark of Death.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a7c58435-b26d-4c41-b212-676c23313821',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fortitude',
  'Spend 1 Chi and 1 shot to reduce your Marks of Death by one.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'af6d3382-bd9f-41fa-aadd-0ac29f4a4a97',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Subdermal plating',
  'Add +7 Toughness vs. damage from sources other than attacks or the use of schticks.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '11c677ab-b390-4af3-8526-7d9ac37725fe',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Corded Musculature',
  'Add +3 Toughness vs. close combat attacks during the first sequence of a fight, +2 during the second, and +1 during the third.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '75ade8d0-3ee5-4b96-85eb-533090264b70',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wait for an Opening',
  '+2 Martial Arts vs. enemies who have made Way- Awful Failures during the current fight. Ask the GM to alert you when this happens.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7ddfc008-5a35-44f6-be66-2dec6815bf39',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Obstacle Course',
  'Pay 1 Fortune to ignore any negative modifiers to Driving from road obstacles and conditions until end of fight.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8fe33874-2c12-4a1c-95ed-2c024a6f2942',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Juncture Adapted',
  'When in your home juncture, ignore any juncture costs for Sorcery.',
  'Magic Cop',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2a6c5146-4784-453a-9772-be9937a952b7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Subatomic Transfuser',
  'Spend 3 shots and take 4 times X Wound Points to remove 10 Wound Points apiece from X allies.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f73b6632-7c84-4606-a8a3-86855c89375e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Bigger They Come...',
  'Toughness is reduced by –5 if you reach 50 or more Wound Points, until all Death Checks from this fight have been resolved.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd5c4e5a4-25ef-46e3-a46a-fa98a74dcd21',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shattered Loyalties',
  'Suitable for: Sorcerer.  Spend 1 shot; if the foe is still active at start of next keyframe, target hero suffers a betrayal from a friendly supporting character in a later scene. Explain these stakes to the players. Usable once per adventure. Use this only if you have a setback in mind.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c6242be8-1b59-4def-bf57-47d5ede995ff',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Trained for Armor',
  'Ignore Initiative penalties for armor.',
  'Masked Avenger',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '524df926-f0f6-4ed2-9b1b-897adc958cc4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Eyes of the Fox',
  'Pay 2 Chi to reduce Wound Points dealt to you by an attack to 3.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0f6eec90-00b7-4a0c-ad5d-8005cd3fbc5c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Garrotte of Destiny',
  'Suitable for: Sorcerer, Supernatural Creature.  After the first sequence, if the foe is up at the beginning of each sequence, all heroes lose 1 Fortune. Explain why this happened when the heroes first lose their Fortune.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '56bb3dac-db28-4aff-a8fc-c68594f5df0c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Acid Blood',
  'Spend 1 Genome point. Until end of fight, all enemies within close combat range take 2 Wound Points each time you take Wound Points from enemy attacks.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f4bfcdac-31cc-4035-8185-9bf0442954d0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Offended Honor',
  'Add +1 Damage for each hero after the first that has attacked it during the current fight.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0d624922-cf7b-4ae4-9213-9f881df51dd9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Unyielding Tiger Stance',
  'Spend 1 Chi and 1 shot. Until the next keyframe, any opponent missing you with a Martial Arts attack takes a Smackdown equal to your weapon’s Damage Value.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd1fc9c4e-5952-43b3-a0f9-2aa7c3ade33d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fire Stance',
  'Until end of sequence, any opponent striking you barehanded suffers 3 Wound Points per strike.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b532400a-8941-48e2-a5e3-6ed0e9bedee8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bullet Deflection',
  'When you are missed by a named foe’s ranged attack while Dodging, drop 1 mook.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5475b92f-a886-4d46-a42a-fc646edf2796',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Eyes on the Back of Your Head',
  'You automatically succeed at Notice Checks. Unless you’re wearing a hat, helmet, or other headgear. Yeah, they’re literal eyes literally on the back of your literal head.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '34d3dbff-1d26-48d2-8498-a623e785aea2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Requires Group Effort',
  '+1 Damage for each hero who has yet to attack the foe during the current fight.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f2196d8c-c6c1-4034-96f3-df6507c4d88e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Gruesome Appearance',
  'When in monstrous form, you gain the Intimidate skill at an Action Value of 12.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '189a7551-2b20-4779-b57c-797365dcba18',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Vehicle Hit',
  'Spend 3 shots and make an Attack against a driver’s Driving AV. The Driver’s vehicle takes Outcome +11 Chase Points, which count as a ram or sideswipe.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '39edac92-e8d3-4787-aadd-a837c59eae06',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Scoped out',
  'Add +1 to Guns, Martial Arts, and Defense vs. characters you have exchanged dialogue with at a previous time or location.',
  'Spy',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bd911119-6130-43de-b72d-e58b814a9bfc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Exile from the Hell of Dismemberment',
  'If another hero receives a Mark of Death, spend 1 shot to remove it. Roll a die. On an odd result, you gain a Mark of Death.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7aff4cee-6a8f-43c2-9cdf-b375ffe3213f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cool Car Jacket',
  'You have the skills Seduction 11 and Intimidate 11, but only when wearing the jacket, and only when it is in good shape. The jacket is like new again at the start of each new adventure.',
  'Driver',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ab852932-3750-418c-b8be-47c226a48787',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flesh Melter',
  'As per Chi Blast. Also: on a successful attack, spend x Magic to give target 1 Impairment from the horrific sight of her flesh melting off. X varies by foe type: 1 for featured foes, 2 for bosses. Targets never suffer more than 2 Impairment from this or any other source.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '218ca6fc-7963-4077-9e69-8b407305a4a9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Slap',
  'After a successful Martial Arts attack, spend 1 Chi. Opponent loses a number of shots equal to your Outcome.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '23066675-ce82-4681-8c2d-de5434c6027f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Yowch!',
  'When you take your first point of Impairment, you suffer an obvious injury to your mechanical parts that others can’t help finding disturbing.  The shot cost of any attack against you increases by your degree of Impairment.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '065741be-85a4-4bc1-9fc7-aae5386df067',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cursed Weapon',
  'Suitable for: Sorcerer, Supernatural Creature.  When a hero misses a weapon attack against this foe, all subsequent attacks using that weapon take a –2 penalty and cost +1 shots. If the hero drops the weapon and then Rearms, the attack penalty and added shot cost go away.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '00ab1112-027e-4dba-9238-dc055bc3160e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Night Dweller',
  'Add +1 attack and +2 Defense during fights that take place outdoors at night.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9acc1477-6b3b-4158-8738-47e81dd1dd60',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Very Strong',
  'Add +3 to all Strength Checks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cd179ae1-8c20-44ca-9df4-d4b6affab33f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Aberrant Spasm',
  'When targeted for an attack, interrupt, spend 2 shots and designate another named character with a lower Defense than yours as a secondary target. If the attack misses you, the secondary target takes a Smackdown equal to the Damage Value of the attacker’s weapon.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a204ef48-e61e-485a-87d9-7b1054005774',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Regeneration II',
  'Your Wound Point total decreases by 4 at the beginning of each sequence.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4d0e562b-52fc-4f38-a393-d0f815bb4396',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Establishing Shot IV',
  'Your first Martial Arts attack of any fight gets a +5 bonus.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '92f6af45-26da-4669-a0c8-8b076aa62d9c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flight',
  'Fly through the air, moving up to 3 m per shot.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '572afbff-138f-45af-a100-9e90dcd71754',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flesh Wound',
  'As an interrupt when you take Wound Points, reduce Toughness by X until end of fight to reduce Wound Points taken to 0. X is equal to the number of the current sequence.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a868f2a6-8f42-4dd8-9971-584c9cad770b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Willow Step',
  'Spend 1 Chi and 1 shot to gain +2 Defense against non-Martial Arts attacks until the next keyframe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8b0eb3c3-77f0-465a-be37-aab9fad9ac99',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hyperadrenaline patch',
  'As an interrupt to any action, take 7 Wound Points to give a boost to an ally.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7a86997e-3842-4cfe-9dc6-47bbe4f8e9b5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rage',
  'When a foe deals 7 or more Wound Points to an ally, gain +2 Martial Arts vs. that foe until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ff996394-3a0d-430b-9391-25f9ac3d29b4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Parting Shot',
  'If the foe successfully Cheeses It despite a hero’s attempt to stop it, the hero takes 14 Damage.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'eda68a4e-9565-46a3-8b2f-652f0a60f30d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pedal to the Metal',
  'When driving as the pursuer in a chase, gain +2 Driving if one or more hero drivers have fewer Chase Points.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a7cf04c3-ee36-413c-9741-7ae97bdf16d1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wisdom',
  'Spend 1 Chi when another player fails a check to gain information or have a contact. You know the answer or a relevant contact.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5bd5c446-9231-4198-9303-1b8e63b5f31e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Adaptive',
  'Spend 1 Chi to gain +1 Defense vs. close attacks and –1 against ranged attacks, or vice versa, until end of fight.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a8d8f60a-5509-4111-b365-c429e146eeba',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Revelation',
  'Spend 2 shots or 1 Magic to tell if something you are directly looking at is real, or an illusion.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '68e32c7c-2e2d-44f7-8d2f-2576ba7aa75a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Blunt the Crane''s Beak',
  'Protect others with your prowess. When an opponent makes a successful attack against one of your nearby allies, interrupt and spend 1 shot to reduce the attack’s Damage Value by 5.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cd9dc145-9652-4b6a-8357-91fcd04a6244',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Trick Arrow',
  'When you attempt stunts with a bow and arrow, either your opponent doesn’t gain the +2 Defense bonus or you can declare a stunt after you roll with an Outcome of 3 or more.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7c63b81d-59d5-4841-bfe2-b7cee15b27e9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Determination',
  'Add +2 to Up Checks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '624b9715-8b31-475d-b8e0-4ad45d58321c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Disarm',
  'The foe’s first successful hit against a hero each fight disarms that hero.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9854f5cd-6e5b-4a21-a969-6ee6bbc77868',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Showy Arrow III',
  'As an interrupt when an ally hits with a Guns attack, spend 1 Fortune and 1 shot to make a +2 Guns attack with bow and arrow against the same target.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '01bb27de-903a-4b77-9093-83b8132f5319',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Unicorn Stance',
  'As an interrupt when targeted for a Martial Arts attack, spend 2 shots to gain +2 Defense. If the attack hits you anyway, you gain +3 Martial Arts on your next attack against this attacker.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7263f975-a3d0-4f9b-bff0-cda5caee8014',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bloody But Unbowed I',
  'Add a +2 bonus to Up Checks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e31a6c26-4df4-43d3-9946-953c9f3028c1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Crusty Defender',
  'Add +2 to Martial Arts and +1 to Defense when defending a feng shui site from attack.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9ed578a1-4e7b-451a-9f1c-a6134b89da17',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Radioactive Exudation',
  'Spend 1 Genome point; until the next keyframe, all enemies within close combat range of you take a -1 Toughness penalty.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e7d1d3f0-88be-41d7-ba92-86b3e780ac5c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Drunken Master',
  'You take no intoxication penalties to Martial Arts or Defense. You take a –2 penalty to Martial Arts and Defense when fighting cold sober, and a –1 penalty if you have had less than three servings of alcohol in the last half hour. You can’t use Drunken Master schticks when cold sober.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'df0c5b4a-be9b-43cb-bdb0-6d362c6ef0d7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Chi Weaver',
  'Add +2 to Martial Arts if you are attacking an enemy feng shui site.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c3aa5f31-b03d-4c50-9171-0df8e6f21cf7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Dread resurrection',
  'Suitable for: Sorcerer.  Spend 1 shot; if the foe is still active at start of the next keyframe, an enemy of the target will come back from the dead in a later scene. Explain these stakes to the players. Use only if you have a dead enemy in mind.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e1d0a442-723e-419a-8638-6e29623f883a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'How Magnets Work',
  'Spend 1 shot and make a Mutant Check against an enemy’s Defense. Until the next keyframe, that enemy must stay within close combat range of you.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2906e57c-b72d-4024-b34a-57581f92bce5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fire Blast',
  'As per Chi Blast. When you take out a mook, spend 1 Magic and roll a single die. On an even die result, you take out another mook and roll a single die. If that result is even, you take out yet another mook, and so on, until you roll an odd result or run out of mooks to take out.  This is also useful for setting fires, lighting cigars and cigarettes in an impressive manner, heating up coffee, increasing room temperature, and thawing out frozen foods.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a2560fd0-f850-454f-908b-1b623ddfbab9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Brain Fortress',
  'Spend 1 Magic to grant yourself or an ally either +3 to Will Checks or a Will value of 12 (your choice) until end of scene.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9ec74dbf-fa4e-41ad-b3c1-13ca7f9bea1e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hypnotic Sidling',
  'Spend 6 shots; an opponent of your choice must spend 6 shots.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7a9a087f-5d22-454e-99a2-1406237fca17',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pounce',
  'Add +3 to Initiative, provided your first action in the sequence is a Martial Arts attack.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd68dddfd-0462-4a23-a3ac-2441dc5c1485',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Slowdown',
  'Spend X Magic and 3 shots to make a Sorcery Check against an enemy’s Defense; if successful, enemy’s Speed decreases by X until end of fight. Speed can’t be reduced below 1.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0416acc3-99a0-4b56-a6bb-527efe7900b5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Escher Blast',
  'As per Chi Blast. Also: on a successful attack, spend 1 Magic to give the combat area the adverse condition Confined Space until the next keyframe.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '71ceb1db-7c78-4a44-8c2a-e5f15f2eb038',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Personal Copter Rig',
  'Spend 1 shot to fly up to 14 m.  An enemy targeting you with a successful stunt attack wrecks your rotor until end of fight, preventing you from flying. Roll a Swerve. On a negative result, take 6 Wound Points.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a6157dbe-ad3d-4c45-a14b-2eb12a5b64b9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shouted Orders',
  'As an interrupt when a mook hits a hero, the foe may spend 1 shot to add 4 Damage to the mook’s hit.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd6964acb-54ee-4f96-8525-aeee62897c40',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hold on Tight III',
  '+4 to Chase Points dealt an enemy vehicle when you close or narrow the gap with it.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '796b07f2-28e3-4dbe-8d4e-25f6f38dcde9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fast Draw III',
  'Add 4 to your Initiative result. Your first action of the sequence must use Guns.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '155244bc-fe77-42f8-a8b3-89f00ba18f72',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Dark''s Soft Whisper',
  'Make any attack completely silently. On a Guns attack, describe yourself using a silencer.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bfd39924-7ef0-46c6-b848-af56fbc6a71c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Chi Blast',
  'As a standard 3-shot action, direct a ranged attack of raw magical energy at a combatant of your choice, using your Sorcery attack value, at a Damage Value of 9.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a3a72902-7ed1-47bc-bea5-18c4b2980457',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Clear Aim',
  'Add +3 Attack vs. characters whose current Defense exceeds their base Defense.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '055590b2-7e1e-46f4-9d25-45645e03a4e2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Prosperity of the Crab',
  'Spend 1 Chi to treat the roll you get on any positive Swerve die as a 5 instead.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '34e60201-72bf-467f-8844-f8ac00fa7197',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Smoke Arrow',
  'When you hit an opponent with an arrow, that opponent suffers a point of Impairment until the next keyframe. The maximum Impairment any target can take from a Smoke Arrow is 1.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '340fad92-96e3-47e6-a24f-db9d73850d87',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Iron Mind powder',
  'Spend 1 Magic to cancel a foe schtick effect that does something to an ally and is otherwise due to expire at the end of the sequence, keyframe, or fight.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '99184687-46ed-45ab-b9a4-05a4e1292d83',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'For the Squad',
  'When you assist an ally with an attack boost, the attack costs the ally 2 shots.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f9dde9a5-08d9-4fbc-890d-2fb2149ac6d6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Divert Blow',
  'Suitable for: Martial Artist.  Spend 1 shot as an interrupt after being hit by a Martial Arts attack; if the attack would deal 5 or less Wound Points, the attack deals 1 Wound Point. Otherwise, the attack deals 3 Wound Points.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '17f807c6-1cec-42f1-a85d-3834c9757cf1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wide Frame',
  'Spend 0 shots to reduce Wound Points taken as a pedestrian hit by a vehicle to 3.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'af5da62c-8530-4a00-bb8c-31c52de331f0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ultragloat',
  'When a featured foe drops, spend 1 shot as an interrupt. Regain lost Genome points up to the number of featured foes still in the fight.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '64017e47-0fcd-4866-9ec4-2bcd49b09772',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Recuperate',
  'Spend X Genome points and 1 shot; your Wound Point total decreases by five times X.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5eb84b6f-89b7-446b-890f-0a756777831b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Take the Shot',
  'Add +4 Guns vs. targets using hostages as human shields.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2ddd8341-54fd-4c02-85d6-c0cbd83bc321',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fast Learner',
  'Add +1 Defense against any opponent who has already hit you during the current sequence.',
  'Thief',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'caa331d1-bc62-427a-abb2-4353bf526733',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Leap',
  'Spend 1 Chi to leap up to 7 m, either horizontally or vertically. Add 7 m to the leap for each feng shui site you are attuned to.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dd6f47f4-07e5-458f-9be2-b7ef35dc8901',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shibuya Slide',
  'When driving as the evader in a chase, gain +2 Driving if one or more hero drivers have fewer Chase Points.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '75842da5-75ff-409d-ac78-8d5862640644',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pause That Refreshes',
  'As an interrupt when a hero makes a Dodge, the foe may remove 4 Wound Points from any foe, including itself.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ccd5528d-6dc9-43f0-b484-d8b8a5ff6017',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ram Speed III',
  'When you ram or sideswipe a vehicle, gain +3 Crunch. +6 Damage Value when you hit a pedestrian.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '63a8709a-fa0d-4c23-b8bd-384a744a4e9f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lone Wolf',
  '+3 Defense if you are the only viable target for three or more named character opponents.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2dc90091-9cdd-47f5-b3ee-af0e3d39c80d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fast Draw I',
  'Add 2 to your Initiative result. Your first action of the sequence must use Guns.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f3a84e86-ecf5-4002-a66f-37dee4e7e135',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'De-Attunement',
  'Spend 2 shots and make a Sorcery Check against the Will Resistance of any foe attuned to one or more feng shui sites. (Featured foes may or may not be; boss foes almost invariably are. Mooks never are.) If successful, target takes 1 Impairment until end of fight.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f8dc6a0c-90c7-49f3-9e7d-f40a71f7b79b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Firm Grip',
  'After a successful autofire attack, roll a die. On an even result, regain a spent Fortune point. Autofire attacks do not change your Reload value.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f8a2276c-17f7-4287-af4c-ef7101737372',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Embezzle',
  'When hit by an attacker with a higher attack AV than yours, you gain the same attack AV as the attacker until the next keyframe.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0b48e6d2-d30f-4b78-978f-2c1d8712a0da',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bullseye',
  'Spend 1 shot or 1 Magic to identify the named foe you have the best chance of hitting with a Chi Blast.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bcf2a31d-d21c-4a2a-9a87-4e69a0e855c9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Exemplary Prostrations',
  'Spend 1 Magic to seem trustworthy to all authority figures present in the current scene. Lasts until end of adventure, or until you actively violate their trust, whichever comes first.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0fd16c31-b7f5-45a0-ac1f-cef054c04ab9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Furious Wrath',
  'If the foe’s last attack missed, its current one gains +1 Attack and +3 Damage. Not cumulative.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '148c4b25-58dc-41e6-9629-f2caa9cabf93',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Luck of the Dragon',
  'If you spend Fortune on a check and still fail to meet the Difficulty, you get the Fortune back.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '37248ddb-d25d-4e13-996e-afc61ed70353',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Domination',
  'Suitable for: Sorcerers, Supernatural Creatures, Scroungetech Opponents with Hypnotic Devices.  The foe spends 1 shot and chooses a hero to make a Difficulty 10 Will Check. If the hero fails, the foe spends another 2 shots, and chooses the target of the hero’s next attack.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '44318b72-3f93-4986-9793-f32e08d05372',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Resource Sniff',
  'Always know the direction to head in to find the nearest source of edible food, clean water, or a particular chemical or element.',
  'Mutant',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '14737818-745e-410f-ac51-eba5cdb9d8a7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tough Hide',
  'Add +1 Toughness vs. Martial Arts attacks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7eb3b7da-ae1d-4b63-91e7-9db5c18f8d03',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flying Weapon',
  'You create from thin air a glowing, magical weapon or weapons — for example, a sword, spear, or rain of knives — which hurls towards your opponent. As per Chi Blast. Also: on a successful attack, target spends 1 shot.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '67c8aae0-bf97-4ecf-9870-8c8ee26089ef',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Forceful Dart',
  'Spend 1 Chi to give your thrown darts or throwing stars a Damage Value of X–1 until the next keyframe. X is equal to the highest base Damage Value of any weapon currently being wielded by an ally (ignoring any special damage bonuses the ally gets, of course).',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '05f729fc-fc29-4612-ae2b-5e32be968c91',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cast Darkness',
  'Create zones of complete darkness, which obstruct characters from finding and targeting enemies.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b4df006c-2de4-4c5b-bfee-9c95237d3f24',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Objects in the Mirror',
  'Pay 1 Fortune as an interrupt after making a Driving Check; all passengers in your vehicle gain +1 to attacks until the next keyframe.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2da1503d-10b9-41c9-9541-92bf1c0f8347',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'T is for Target',
  'As an interrupt after a failed attack on a hero, spend 1 shot; up to three mooks, as an interrupt, may attack the hero. Usable once per sequence.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a7883bd9-deb1-4c43-9c98-37efd026a1fa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Doom Boon',
  'Regain all spent Magic points after succeeding at an Up Check.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'aed6e6b8-8afd-44e1-aa76-69da09509c4d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Water Sword',
  'When you hit a named foe, a number of named foes equal to your Swerve lose 1 shot each, if your Swerve is more than 1.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '088e6319-644f-431d-836c-878559316fee',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Time-Tested Tech I',
  'As an interrupt when an enemy fails a Reload roll, spend 0 shots to make a Guns attack with a bow and arrow against that enemy.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e613160a-219f-45dd-b321-9020af778988',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Coiled Strike',
  'Make a 5-shot Martial Arts attack at +3. If successful, opponent loses 1 shot.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dd67203e-c30c-4f42-a82f-f428bdd555fa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Inspire Fanaticism',
  'When a weapon-wielding hero announces an attack against a foe while at least 1 mook is still up, the foe spends 1 shot as an interrupt. One mook goes down. Roll a die. Odd: the attack is nullified, and the hero is Disarmed.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'aa582fde-c5bd-4234-8f46-25975cf4c6e6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Reflex Ramper',
  'When an attack misses, take 1 Impairment to make a new attack on the same target as an interrupt. This Impairment goes away at the beginning of the next session.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fa8d4968-85ea-4c62-bee3-ba5d0281aacc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hardy',
  'Spend 1 Chi when you take Wound Points outside of a fight. Number of Wound Points dealt is cut in half, rounding down.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '70cc9421-2ebf-40a8-af61-ac0387ddf882',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cyclical Flow',
  'Suitable for: Martial Artist.  Damage equals current shot number +5.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '071c544e-edfa-41cf-afce-dd8fae4e4d5b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rattle',
  'Spend 1 Chi and make a Martial Arts Check against a foe’s Will Resistance. On a success, the foe takes 7 Wound Points the next time it attacks you. The foe is aware of this effect and can avoid it by attacking other heroes.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8ad53b44-fad8-4650-8616-36e0d985f9aa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heal Steal',
  'Suitable for: Sorcerer.  As an interrupt, when a hero uses an effect that reduces any hero’s Wound Point total, the foe spends 1 shot and checks Sorcery against the effect- user’s Defense. On a success, the effect is dissipated, and the foe spends 2 more shots.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3a1d6adc-393d-4f2d-b652-30cd10dbe981',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'You Scratch My Back',
  'When an ally gives you a boost, the ally also gets the boost’s benefit.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8259e35a-9508-48f6-8a9d-a6f649dc6207',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Claw',
  'Add +6 Damage when your Martial Arts attack hits an opponent during an even-numbered shot.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '26378a21-8d7d-45b4-b63b-6b5bad5d4a3e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Truthseek',
  'Spend 1 Magic to tell if someone talking to you in person is speaking the truth as he knows it. Spend 1 more Magic to know the real truth, at least as far as the speaker understands it.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '54eabed0-4b0f-46c7-bf37-4ce69f0346a2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bank Shot',
  'After a Guns attack against a mook fails, add a free Fortune die to your next Guns attack.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '79049aab-760e-4380-9314-68d46341624b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lumbar Scorpion',
  'A processor wired into the base of your spine keeps your body going after brain death.  Ignore the effects of failed Up Checks until end of fight. At the end of a fight in which you made 1 or more Up Checks, gain an additional Mark of Death.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5a8cbf6e-2fe3-4b1d-9d5d-689461e88d6c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Purification',
  'Spend 1 Magic and 3 shots to levy a –1 penalty to the Attacks, Defense, and checks of all creatures engaged in the fight, until the next keyframe.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bc7f97b2-ae04-4a47-a53a-c66c97420735',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Laser Goggles',
  'Make ranged Scroungetech attacks with a Damage Value of 11.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0c6289df-693d-48f1-b17f-39b5e441966c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Broken Trigram',
  'Suitable for: Sorcerer.  Spend 1 shot; if the foe is still active at the start of the next keyframe, target hero suffers a financial setback in a later scene. Explain these stakes to the players. Usable once per adventure. Use this only if you have a setback in mind.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6da53f54-e24a-4857-a9af-5bff67a62a90',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ram Speed II',
  'When you ram or sideswipe a vehicle, gain +2 Crunch. +4 Damage Value when you hit a pedestrian.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '11dbcd71-44ee-429b-ba17-2240279b50fc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Vampire Rounds',
  'When you hit multiple opponents with a ranged weapon attack, add a Damage bonus to one particular firearm equal to the number of opponents hit. Bonus lasts until end of fight. This may apply to multiple firearms but will not stack on the same firearm.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '51cd5490-9005-4546-9f27-2cbe1a16b17b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cure Disease',
  'Spend 3 Magic to cure any terminal illness, 2 to cure any serious non-fatal illness, 1 to cure any minor debilitating ailment.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd70b1fbc-63bb-4e61-989d-e9d7c8cdc09f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Serpent''s Tooth',
  'Add +2 Defense vs. any foe you have ever made a successful Seduction Check against.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '471f9d94-089c-4e97-906a-d7198ebd6286',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Influence',
  'This schtick allows the spellcaster to affect the emotions, thoughts, and sensory input of humans and other intelligent beings.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4bbd5ea4-46dd-46b0-aa90-48796446276a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heal Vehicle',
  'Remember what we just said about transitive numinosity? Reduce the Condition Points of any vehicle by the result of your Sorcery Check. In combat, takes 3 shots.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '03fd95f9-fce5-425c-87e9-f5962ccae924',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stave off Monkey',
  'When an opponent makes a successful attack against you, interrupt and pay 5 shots; the attack fails.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e825f5f4-39d4-45a5-9c56-9df6e98a87b9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'One-Inch Punch',
  'In a fight under the adverse condition Confined Space, spend 1 Chi and 0 shots to gain a +2 Immunity bonus until end of fight or end of condition.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9adb8e53-9972-4fc9-8ae8-5d143dc0c86d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shower of Sparks',
  'The Smackdown of your Scroungetech attacks increases by 2 for each point of Impairment you’re currently suffering.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dbe4baea-82ce-4efe-ba97-8683b7825ebb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ram-alama-bam',
  'When driving, if the foe rams a vehicle, gain +2 Frame. Also, +4 Damage Value when the foe hits a pedestrian.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd46653b4-dfd2-42db-aeb3-a8c73c71162f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Amphibian',
  'You can easily move, breathe, and fight underwater.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0455095a-3bf8-40d3-bbd4-f7f28ea6a8d2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning Blast',
  'As per Chi Blast. Also, on a successful attack, spend 1 Magic to require your target to spend 3 shots recovering from a stunning effect. Targets with Constitution Checks above 7 spend only 1 shot.  Spend 1 Magic to recharge or power any electrical device. Device works for one scene.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fe336241-9374-4f3c-96b4-cfcfb45170e9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Last rally',
  'As an interrupt after taking Wound Points that bring the foe to a total of 35 or more, the foe makes an attack against any hero, at +2 Attack and +6 Damage.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f1b95582-01f0-4421-8f2b-539d51583ace',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Onboard Flamethrower',
  'Make ranged Scroungetech attacks with a Damage Value of 14. Each time you attack with it, take 3 Wound Points.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '00bc8f4e-36d7-4b42-863f-5b6a348d9a44',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Muscular Infusion',
  'Spend 1 Magic to grant yourself or an ally either +3 to Strength Checks or a Strength value of 12 (your choice) until end of scene.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'af6acff0-e124-4f1d-8d2f-6f7fb93d4769',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Deserter from the Hell of Flaying',
  'Spend 1 shot to make a hero immune to Impairment until end of fight.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '103cae55-5a4c-4739-8d2b-9570192a31c4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Oops, Forgot that One',
  'You always fail Concealment Checks. If searched for weapons, the searchers always find everything you’re carrying and completely disarm you. Even if you said you got rid of all your weapons, they always find at least a hidden ankle piece. (This does not mean that you always have a weapon.)',
  'Full Metal Nutball',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd6bacc62-f14c-4bf5-9528-9d6081a9feb1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fatal Reversion',
  'Your dragon form can only survive in magical environments.  If you are reverted to dragon form in a magic-hostile juncture, you die.',
  'Transformed Dragon',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '241d012a-0a6c-4a63-985f-6e96556024f1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Regeneration III',
  'Your Wound Point total decreases by 5 at the beginning of each sequence.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4009c6d3-f74d-4de9-b83e-fbd7f4daee98',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Time-Tested Tech II',
  'As an interrupt when an enemy fails a Reload roll, spend 0 shots to make a +2 Guns attack with a bow and arrow against that enemy.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '018a0b97-e33a-437d-9cfe-97849e3aac6f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Headshot',
  'After a successful attack, the foe may decide that a hero takes –2 penalty to skill checks until beginning of a subsequent fight. This effect may extend into a future session. Usable once per fight.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '908ffc5a-762e-4e60-b5c7-98fbb84f345e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shoulder the Brunt',
  'When a nearby ally takes Wound Points, spend 1 shot as an interrupt. You take the Wound Points instead.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'aaec7ba9-f4a3-44b7-9096-8fe927a871ab',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stop Right There!',
  'Spend 1 shot to automatically stop an enemy from Cheesing It.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '25665755-300b-441e-b556-b642ed927115',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Toxic Strike',
  'Spend 1 Chi as an interrupt after making a successful Martial Arts attack; if at any point during the fight the target reaches 30 or more Wound Points, it then immediately takes another 5 Wound Points.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3417cdf3-8b58-477c-bc8c-4aceec3b6632',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Inspire Loyalty',
  'When this foe goes down, all active featured foes make an interrupt attack against a hero of their choice at a shot cost of 0.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a4886752-3e1b-4bbb-811e-ac0357ce4914',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Scuttle',
  'Add +2 to Martial Arts vs. featured foes and bosses, if your previous attack was against a different featured foe or boss than the one you’re attacking now.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '79948b66-7e11-449f-b605-cd02487559d8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Corners of the Mouth',
  'Allies may spend 1 shot and 1 Fortune to give you 1 Chi.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '96547bcc-88c4-425c-85c5-01600543a314',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Kinetic Distributor',
  'Spend 1 Fortune as an interrupt when targeted by a close attack. Gain +5 Toughness. If the attack deals you no Wound Points, roll a die. On an odd result, pick an ally to take 12 damage.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8a3338c5-e2ec-49a7-9673-a697eeaa8401',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rage Outside the Machine',
  'When you are the only PC in a scene, or your vehicle has 35 or more Chase Points, gain +2 Martial Arts.',
  'Driver',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e5ec5094-6ee9-4572-9e26-26b6c18828ef',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Robot Arm',
  'Make close Scroungetech attacks with a Damage Value of 11.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fa28078d-5d53-4cd5-a52f-d1a583714a23',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Omnicompetent',
  'If no other PC present for the current session has a value of 13 or more in a given skill, spend 1 Chi to gain a value of 15 in that skill until end of session.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b41fd753-911a-4c48-80d4-26e4c00c8e77',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Spin the Cylinder',
  'Suitable for: Featured foe with Guns attack. After Reloading, the foe’s next attack is at +2 Attack and +6 Damage.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0d3df1d1-b661-4ca6-8a24-ff6a2db55314',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Prodigious Leap',
  'Spend 1 shot to make a horizontal, vertical, or diagonal leap of up to 14 m. Also costs 1 Chi, if your current Chi is less than 2. If you have two or more other schticks in the Welcoming Sky path, leap increases to 28 m.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '082c9336-9c5f-47d7-94a7-293e8d34211c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Severed Love Line',
  'Suitable for: Sorcerer.  Spend 1 shot; if the foe is still active at the start of the next keyframe, target hero suffers a romantic setback in a later scene. Explain these stakes to the players. Usable once per adventure. Use this only if you have a setback in mind.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1372ba50-4aa8-46d9-ad8e-bf700b5cd1e5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Back Leg Kick',
  'Add +1 Martial Arts vs. the opponent most recently targeted for attack by any of your allies.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd0c2ff87-1e37-4980-aa13-af1a5dc7c3cb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hungry Fire',
  'Spend 1 Chi and make a Martial Arts punch attack against a named enemy. On a success, spend 2 shots per named enemy. All named enemies take 5 Wound Points.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '77321776-a785-4a40-be86-7e7e25bab285',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Strike from Darkness',
  'On a successful Martial Arts attack against an opponent previously unaware of your presence, your Smackdown is not reduced by opponent’s Toughness.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e6049c24-e934-45d7-ae53-6d615c9bf222',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Arctic Blast',
  'As per Chi Blast. Also: on a successful area the adverse condition Snow until the next keyframe. When the condition expires, roll a single die. On an even result, it renews until the next keyframe.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '75eb55b3-5be2-4a4f-8fd9-ce3c82c3de7f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mimic Form',
  'Suitable for: Martial Artist.  Spend 1 shot as an interrupt after taking Wound Points from an attack with a Damage Value higher than any of the foe’s weapons. The foe’s Damage Value now equals that of the attacking hero.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1ef583b2-2c47-41bf-abf2-84ea8a70b4a5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cut the Bull',
  'When you and the other PCs are speculating as to the best course of action, or as to the motivations of a given character, you can spend a Fortune point to have the GM tell you whether your speculation is correct or incorrect.',
  'Private Investigator',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b434cf50-1b52-484b-b93d-cc1f3fc6ebb3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Thunder Strike',
  'On a successful hit, the target is shocked with lightning, spending 1 Shot.

If the Smackdown is greater than 5, the target spends 3 Shots.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '30943a86-d46f-47fa-bbf0-e9832b3979bd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Explosive vest',
  'All nearby heroes take a Smackdown of 12 when the foe goes down.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e70b4f78-d6ec-434a-ab14-0dc3aeeec0a8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fast',
  'As an interrupt after Initiative results are determined, spend 1 Chi to switch your opening shot for the sequence with that of any other combatant.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ec00c243-f8be-4317-973f-523a930b0d0e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hold Them off',
  'Add +2 Martial Arts and +1 Defense when one or more allies has fled the current fight.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5e0da9f5-f2b7-4056-934d-dbb4461c0345',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Swerve I',
  '+1 Frame when rammed or sideswiped.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8ee14117-5981-4132-894e-89156a402f4f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Scamper',
  'As an interrupt after you take Wound Points from an attack, spend 1 Chi and roll a die. Substitute the die roll result for the number of Wound Points you would otherwise take.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dd69fb59-5d12-441f-bd31-ce52c3880f95',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Taskmaster',
  'Suitable for: Boss.  Add +3 to featured foe Initiative while the boss is up.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7a51d49b-cf1e-48fd-996d-10569f7394da',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Delayed Death Strike',
  'Suitable for: Martial Artist.  On a successful unarmed strike, the target hero starts their next fight with 1 Mark of Death. Usable once per fight.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '89471f44-cf59-4a4a-9e0b-9b94bb3e80fd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Riveting Gaze',
  'Spend 6 shots; an opponent of your choice must spend 6 shots.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5af7c13a-cf58-4325-a916-618de11423af',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tarmac Warrior',
  'If you exit your vehicle after making at least one Driving Check, +2 to your attacks until end of fight.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4440b1aa-0286-43ab-a526-497744d6b763',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Very Clever',
  'Spend 1 Chi to automatically succeed at a single skill check, with an Outcome of 2. Attack Checks are not skill checks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '76231595-9247-4e0b-be38-b27d3a0d5465',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Laughter of the Fox',
  'After a successful Martial Arts Check, roll a die. Even: gain +1 attack against the foe you just hit until end of fight. Odd: gain +1 Defense against the foe you just hit until end of fight.  Bonuses against the same foe accumulate over multiple successful hits.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '57dedf93-a30c-4188-ab01-bc12f723eb1b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shield of the underdog',
  'Spend 1 Chi and 1 shot as an interrupt when struck by an opponent whose Defense value exceeds yours. Your Defense increases to equal the opponent’s (as of your use of this power) until end of fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5f35cfc2-581d-4ca3-872b-5550add9236f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lone Wolf',
  'Add +3 Defense if you are the only viable target for three or more named character opponents.',
  'Drifter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f2bdfa81-883e-4564-993f-936d5ed6e99d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bloody But Unbowed III',
  'Add +4 bonus to Up Checks.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bd63d69c-1750-419c-ac56-ef8fdd5abd55',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Self-Sure',
  'Add +3 to all Will Checks.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ef62ac7a-f3e5-42e1-8fb2-2a5d1ce8253f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Highly Trained',
  'At the beginning of any fight, you may swap your Guns and Martial Arts attack values. Swap remains in effect for duration of fight.',
  'Ex Special Forces',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3f146900-cf64-4aad-8ae3-e8c73d5dd199',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Corruption',
  'Spend 1 Magic and 3 shots to grant +1 to the Attacks, Defense, and checks of all creatures engaged in the fight, until the next keyframe.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1b5e73cf-1bfe-4335-853c-0c215d3a6c7b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hate Potion',
  'Spend 1 Magic to formulate a potion which, if ingested by a featured foe or supporting character, causes him to curse and despise another character specified by the sorcerer at time of formulation. At the end of each subsequent scene, make a Sorcery Check against the target’s Will Resistance. The effect ends when you fail a check, or at end of session, whichever comes sooner.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7c0eefaa-8d66-46e9-b34b-0b26aecb22ac',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Vitamin S',
  'Spend 1 Magic to grant yourself or an ally either +3 to Constitution Checks or a Toughness value of 12 for the purposes of making Constitution Checks (your choice) until end of scene.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7594a33e-0c93-408a-b0bb-f64e0a430c4a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Disarming Shot',
  'Take a -1 penalty to your attack roll against a foe carrying a weapon. If your attack hits, the foe drops the weapon.The shot cost of its next attack increases by 3. After this attack the foe is considered to have its weapon back. The penalty to your attack is -3 against bosses.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9d318f13-98ab-4968-978d-03a78d444892',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ammunitional rescue',
  'After using Like the Cavalry, your first Guns attack gains +4 bonus. For the rest of the fight, you get +2 to Guns, Martial Arts, and Defense.',
  'Drifter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '138d5bd0-154a-4229-9d11-0a0983cdb131',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stoke the Fire',
  'Under the adverse condition Extreme Heat, spend 2 Chi to gain a +2 Immunity bonus to Martial Arts and Defense until end of fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6d39c6e4-557b-4ecf-b77b-474d3dd72ad2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lethal Strike',
  'Any time after the second sequence, spend 1 shot and take 1 Mark of Death to down a featured foe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '669778c0-9fc1-4ce9-a413-452b500b6263',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flashing Katana',
  'When you hit a named foe, give one ally a boost.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0ede56d8-aa7a-47e3-8ee6-c6b50ea23bbe',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning Reload II',
  'Add 2 to the results of all Reload Checks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a37d53f4-402c-4e55-982c-dba982a8e1a2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Click Click Toss II',
  'When you fail a Reload Check, spend 1 shot as an interrupt to toss your emptied gun ineffectually toward your enemy. Add +8 to your next Attack Check.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ce9d0084-6534-47e6-a8e7-d2fd9c78a7de',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Trapping Hands',
  'Spend 1 Chi. Until the next keyframe, opponents making Martial Arts attacks against you must pay +1 shot to do so, and another extra shot if they miss.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9b18c95d-8847-43b7-94a0-d0266b4ea03a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Walk of a Thousand Steps',
  'When you take 5 or more Wound Points from a non-Martial Arts attack, your next action occurs on the next shot. It and all subsequent actions carry their usual shot costs.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4c26b554-1645-42af-9be1-8195877c74f9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bloody But Unbowed II',
  'Add +3 bonus to Up Checks.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '17656b83-9bd1-4d71-91bb-93cbc999bfa2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Drunken Fist',
  'Spend 2 shots to make a Martial Arts attack at –2 AV, or spend 1 shot to make a Martial Arts attack at –4 AV.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '34aec6d3-3976-4276-963b-351de527644b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tiger Stance',
  'When targeted for a Martial Arts attack, interrupt and spend 2 Chi to make one Martial Arts attack against your attacker, resolved before the original attack.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd94b4ff0-24c4-4ea7-a376-11c0bb9129fc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Floor It II',
  '+2 Handling when an opponent narrows the gap with you.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a869dfb7-3476-4683-9a37-180905729475',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bag Full of Guns II',
  'Start each fight with a revolver (9/2/6). Each time you attack a named foe and fail to dish out more than 15 Wound Points, spend 0 shots to move to the next item in this gun list: Colt 1911A (10/2/4), Desert Eagle .357 Magnum (11/3/3), Chiappa Rhino (12/3/5), Mossberg Special Purpose (13/5/4), homemade shotgun (14/5/4), homemade rifle (15/5/1). Homemade weapons fall apart at end of fight. Only you can use them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8d38f409-cb8a-4061-a480-1294f9358583',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Enforced Tranquility',
  'When targeted for a Guns attack, spend 1 Chi and 1 shot as an interrupt.The attacker’s gun malfunctions.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c7354d34-e268-4cc0-9d35-0bc6b1bd402e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shed Skin II',
  'As per the above, but you can also duplicate particular individuals well enough to be mistaken for them. Spend any amount of Chi. People who know the subject you’re imitating get Notice Checks, one per viewer per scene, to spot the imposture, with the Difficulty equaling the amount of Chi you spent times 3. The transformation conveys no particular ability to imitate the individual’s voice, speech patterns, mannerisms, or anything else beyond visual resemblance.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '910e0d39-2532-4f42-9cc1-2d5979d4143e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Carnival of Carnage III',
  'Add +2 Guns vs. mooks. Subtract 1 from the shot cost of any attack on a mook or mooks. Minimum shot cost remains 1.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c2c87dfe-30aa-4e79-92c7-67da99b17fe8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Counterslam II',
  'Opposing vehicles take +6 Chase Points from Bumps.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '838e7fb0-c0c5-4208-9fd1-0148e6787eee',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mantis Stance',
  'Whenever a named character deals you 8 or more Wound Points with a close combat attack, attack that foe as an interrupt.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '473ad472-4ab6-4420-995e-f45fe2cff60a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tail of the Dragon',
  'Add the number of featured foes and bosses you have inflicted Wound Points on during the current fight to your Speed.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4448f07e-6d76-4edd-bc9e-2f9ba69fbb88',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Swerve II',
  '+2 Frame when rammed or sideswiped.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'eddaaa8a-7ace-4cba-aa46-3c1538a55521',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rain of Pain',
  'On a successful nunchaku attack against multiple opponents, add an additional nearby foe as a target of the attack for every point of difference between the Outcome you needed and the Outcome you got.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd7e3578e-5e5e-4fae-b2f7-54452030c004',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Healing Chi',
  'In a lightning-quick series of moves, jab crucial acupressure points of a wounded patient in order to dramatically speed up his natural healing process. Spend 3 shots and 1 Chi to reduce a character’s Wound Point total by the result of your Martial Arts Check.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ae851c64-5523-49d1-a12d-2b328600de8c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Both Guns Blazing IV',
  'Fire two guns simultaneously at your opponent; these must be handguns or otherwise outfitted with a pistol grip. Treat as one attack at Guns +1, with the Damage Values of both guns added together, and the opponent’s Toughness doubled. The next time you are attacked this sequence, you get a +1 Defense bonus.  Make one Reload Check for both your guns; one reload action reloads both of them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '834cb7b7-a43d-4ccf-b42a-ff98fbd8953d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cyclone of Wood and Chain',
  'After a successful Martial Arts nunchaku attack, spend X shots. Your opponent must also spend X shots. X may not exceed 6.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b4a9159f-3c6f-4bc2-8305-2f82ded627f5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Time-Tested Tech III',
  'As an interrupt when an enemy fails a Reload roll, spend 0 shots to make a +3 Guns attack with a bow and arrow against that enemy.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '5888483a-b781-4d9b-aad2-bc7deb240acf',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Panther Pounce',
  'If you are the only PC in a scene and you encounter a single GMC, spend 0 Chi (for a mook) or 2 Chi (for a named character) to knock out, daze, or otherwise render the target helpless and unable to interfere with you. This lasts for five minutes, or until you try to harm the character, whichever comes first.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ac728c89-154e-4137-a1de-13a3aa43c26e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Power of Love',
  'Cradle an (apparently) dead comrade in your arms, weeping and wailing until your tears spatter his face. Spend 1 Chi when an ally who is close enough for you to touch fails a Death Check. Your ally lapses into immediate, death-like unconsciousness but gets to make a new Death Check.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '166529ee-43a6-464b-8dab-e38707fbba4d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Gathering the Darkness',
  'Draw the darkness and shadows in the area towards you like a protective cloak. Add +2 Defense against foes who have not yet hit you during this fight.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a158e36f-4681-4a20-8d2f-ecda3bbcf303',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fast Draw II',
  'Add 3 to your Initiative result. Your first action of the sequence must use Guns.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ff6923dd-196c-4447-8996-6f28a386cd46',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rustling Leaves',
  'When you take 5 or more Wound Points from a Guns attack, the attacker must Reload.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7f382d87-ebbe-46ef-b613-cd7500fcd98e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bloody But Unbowed II',
  'Add a +3 bonus to Up Checks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '912fad4c-792d-4e8f-b978-c81564dab69d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'No-o-o-o-o!!',
  'Spend 1 Chi and 1 shot as an interrupt when an ally makes an Up Check. Until the end of fight, add the total number of Up Checks made by allies this fight to the Smackdown you deal on a successful attack.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a75227ee-f4aa-443c-b925-b497ca2becc3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bag Full of Guns III',
  'Start each fight with a revolver (9/2/6.) Each time you attack a named foe and fail to dish out more than 20 Wound Points, spend 0 shots to move to the next item in this gun list: Colt 1911A (10/2/4), Desert Eagle .357 Magnum (11/3/3), Chiappa Rhino (12/3/5), Mossberg Special Purpose (13/5/4), homemade shotgun (14/5/4), homemade rifle (15/5/1), homemade rocket launcher (16/5/4), homemade shoulder-mounted Gatling (17/5/1). Homemade weapons fall apart at end of fight. Only you can use them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '16562cdf-e300-4ede-a499-5f1fb954af65',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ominous Flutter',
  'Spend 1 Chi. Until the end of the fight, any attack you immediately precede with a Prodigious Leap gets a +1 bonus.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f60888a4-f88f-487e-afcd-49b4c9be9b97',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fire Fist',
  'Strike an opponent barehanded with your fist wreathed in a nimbus of chi energy. Spend 1 Chi and make a Martial Arts punch attack against a featured foe or boss. On a success, target must check Toughness against the Smackdown. On a failure, opponent takes 3 Wound Points each time you make another attack against any opponent, until the next keyframe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2eab7af3-df31-4ac7-a1a3-78a1a0561ba5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Underdog Triumphant',
  'Standard attacks against foes whose attacks have forced you to make Up Checks cost you 2 shots.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ea04152e-5c0a-40f7-98a3-42f50c3731bd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Chop the Willow',
  'After a successful Martial Arts attack against a foe with 1 Impairment or less, spend 2 Chi and 1 shot. Target of the attack gains 1 Impairment until the next keyframe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4da3e312-6199-4439-96a8-5063597bed11',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Battle Scavenge II',
  'You gain +2 to Rearm Checks.  You may respond to a failed Reload Check by arming yourself with the weapon formerly carried by a fallen gun-wielding opponent. You may choose the best of the opponent’s weapons that has not already been picked up. This action costs you 2 shots and allows you to carefully replace your previous weapon. You gain a free Fortune die on your first attack with the scavenged weapon, and regain 1 spent Fortune point.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '473d9937-d6ef-47b4-940c-fbb892d5b6de',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Contract of the Fox',
  'Spend 1 Chi immediately after Initiative is determined. Your Initiative result equals that of the combatant with the highest Initiative.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6b7dba52-7f60-4a35-b230-a071bf86f07b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Beard of the Dragon',
  'Spend 1 Chi and 1 shot. Until the end of the fight, targets of your failed attacks nonetheless take 3 Wound Points per attack.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a60112c0-e45a-4730-9e39-8fe62f4736a3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Vengeance of the Fox',
  'When you are hit by a Martial Arts attack, spend 1 Chi and 1 shot as an interrupt. Make a Martial Arts Check against your attacker’s Defense. If successful, the opponent is thrown a number of meters equal to your Outcome in the direction of your choice. Opponent takes a Smackdown equal to his Strength Check value (usually 7) plus the Outcome.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ad80b645-3b7b-4949-ba24-d81ca8042f68',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Blur of Rage',
  'Spend 1 Chi as you make a Martial Arts nunchaku attack against a mook. Until the next keyframe, roll a die whenever a mook attacks you. On an even result, the mook drops before it can attack.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dcbcc453-b0da-4c20-a921-cb8092bd61f2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Click Click Toss III',
  'When you fail a Reload Check, spend 1 shot as an interrupt to toss your emptied gun ineffectually toward your enemy. Add +11 to your next Attack Check.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd84e383f-cb18-49d0-b3a0-a015fe393944',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Turn the Tables',
  'If the number of named opponents exceeds the number of heroes taking part in the current fight, spend 2 Chi and 1 shot to give all allies +2 to attacks until the next keyframe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ff2da630-014e-4792-95f9-a4ba3dffc740',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Point Blockage',
  'After making a successful Martial Arts Check, spend 3 Chi and 1 shot to prevent your opponent from taking actions until the next keyframe, or until opponent takes 3 or more Wound Points, whichever comes first.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'de5f3ae3-8097-4e0b-8bfb-272ea023d537',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Aerial Pushaway',
  'Evade an enemy with a graceful midair backflip. When an enemy misses you with a Martial Arts attack, spend 1 shot to fly up to 14 m backwards, away from your enemy. Regain 1 spent Chi point.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c010af18-290d-4473-a9a5-ce729216a1c7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Vengeance of the Tiger',
  'When you take 10 or more Wound Points from a Martial Arts attack, spend 3 shots as an interrupt to make a +3 Martial Arts strike against the original attacker.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a6808cb0-e567-4629-b687-d94495f73dc4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rapid Volley',
  'When you wound an opponent with an arrow, spend 1 Chi and 3 shots to deal that many Wound Points again to the same opponent.',
  'Archer',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8c438c3e-7c2c-47ec-9540-a4fa1120e292',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Establishing Shot V',
  'Your first Martial Arts attack of any fight gets a +6 bonus.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8f2259bc-d87e-472b-875f-52fde99a8918',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mounting Fury II',
  'When your Mounting Fury bonus allows you to hit an opponent you would otherwise have missed, add +1 Damage.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1e188a52-19fe-47bc-a189-a0c0c437a3d4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Counterslam III',
  'Opposing vehicles take +9 Chase Points from Bumps.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '31603b50-4cef-4a64-8410-49cf05fdaad5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tools of the Trade',
  'After you make a successful Martial Arts attack with a wrench, tire iron, or improvised blunt weapon, spend 1 Fortune as an interrupt to give it a Damage Value of 15 until the next keyframe.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '569e9198-2138-45d8-9938-73f73b62cd05',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Vroom!',
  'If you are in the driver’s seat of a vehicle at the beginning of a sequence, spend 1 Fortune to gain an Initiative result 1 higher than that of any other fight participants. Any other heroes with Vroom! go during the same higher shot as you, by player seating order.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '585bc1bb-e0a3-4836-bf96-a5fa775e0764',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hold on Tight I',
  '+2 to Chase Points dealt an enemy vehicle when you close or narrow the gap with it.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '61eb9666-1f56-4e83-b756-3aa6dc8b5dde',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Custom Ride',
  'You own and usually drive a customized vehicle, one you know down to every quirk and rivet. Compared to the standard model, it gets +1 to Handling and Squeal.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '67f0f9f5-16fa-4c55-abdc-92ef21936d9a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Swerve III',
  '+3 Frame when rammed or sideswiped.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7ebb16b4-7a7c-45e2-bcde-01ed75832393',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hightailing It',
  'Spend 1 Fortune to get +2 Driving until the next keyframe when you are the evader in a vehicle chase. You can’t acquire this schtick if you already have Hot Pursuit.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9e3c77e1-0240-424e-b4c7-bdeb84772e92',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Armor Plated',
  'You own and usually drive a customized vehicle whose body you have strategically reinforced. Compared to the standard model, it gets +1 to Frame and Crunch.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a7149945-bfbc-4198-8d5b-ef2b87e3df27',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Takes a Licking',
  'As an interrupt after your vehicle takes Chase Points from a ram or sideswipe, or a character attack or stunt, spend 1 Fortune and 1 shot to reduce your vehicle’s total Chase Points by 7.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'eb699b26-23f1-4b27-a293-97c9bdeeda30',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'I Just Painted That',
  '+2 Martial Arts vs. any character who damaged your vehicle, even superficially, during the current session.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f09b89fd-5a95-44b5-915f-edc021cc529b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hot Pursuit',
  'Spend 1 Fortune to get +2 Driving until the next keyframe when you are the pursuer in a vehicle chase. You can’t acquire this schtick if you already have Hightailing It.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'e0413694-1120-49f7-8dd7-2d16591d2033',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Dazed and Contused',
  'Until the next keyframe, enemies getting out of a crashed vehicle you at any point rammed or sideswiped take 1 point of Impairment and add 1 to all shot costs.',
  'Driving',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '329fa762-745f-444f-b421-d722f9752240',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Battle Scavenge I',
  'You gain +1 to Rearm Checks.  You may respond to a failed Reload Check by arming yourself with the weapon formerly carried by a fallen gun-wielding opponent. You may choose the best dropped opponent weapon that has not already been picked up. This action costs you 3 shots and allows you to carefully replace your previous weapon. You gain a free Fortune die on your first attack with the scavenged weapon.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '33cbbf8d-1707-47e9-949b-160f0aa33e27',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bloody But Unbowed III',
  'Add a +4 bonus to Up Checks.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'a488f348-6b51-4209-bf19-6cf987e26e55',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Wuxia Archery',
  'At the outset of any fight, note the highest Damage Value of any firearm carried by an ally taking part in the combat who attacks with Guns. The Damage Value of your arrows is 1 less than that.',
  'Archer',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '075754fd-1256-42ea-b4c6-39c6c9d52d36',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hard to Kill',
  'If you fail an Up Check, spend 2 Chi to spring back into action X shots later (where X = the absolute value of the Up Check Outcome) with a Wound 2 Point value of 24.',
  'Bandit',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0cef80af-461f-46fe-8083-57f18385be03',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Irascible',
  'Whenever someone tries to intimidate you, you must spend 1 Chi or act on the irresistible urge to smash someone or something.',
  'Bandit',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4f9bd680-e57f-4338-89b2-c2e87a0f1390',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Survivor''s Roar',
  'Add +2 to a Martial Arts attack if you took damage from an enemy attack since you last made an attack of your own.',
  'Bandit',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '78f99644-e68d-4091-86b5-d2c4d5c63061',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Strong',
  'Add +1 to your Damage on any successful Martial Arts strike, including strikes with hand-to-hand weapons. (Damage Values for your starting weapons already include this bonus.)',
  'Bandit',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '06c3b114-a217-4a7b-97a7-447a55b828eb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Establishing Shot I',
  'Your first Martial Arts attack of any fight gets a +2 bonus.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0a450a4e-25a6-4aa0-a268-a3f9df2384d2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mounting Fury III',
  'As Mounting Fury II, but your Damage Bonus is +2.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2f539aae-852e-4f43-9f5c-d12c47135e34',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mounting Fury I',
  'If you miss with a Martial Arts attack, you gain a +1 cumulative bonus to your next Martial Arts attack. The bonus resets to 0 after you hit, and at the end of the fight.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '451dec46-cf2d-4411-a1e9-13df1d0871c7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Healthy as a Horse IV',
  'You get a +6 bonus to Constitution Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '81ee617c-8cf0-48d5-a531-055afdaa0412',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Strong as an Ox IV',
  'You get +6 to all Strength Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9eddd653-8d3e-4b9a-9025-19aaa4ebb4c7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Establishing Shot II',
  'Your first Martial Arts attack of any fight gets a +3 bonus.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bdd52b93-be67-449c-b454-fa2bd6ddd7b3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Establishing Shot III',
  'Your first Martial Arts attack of any fight gets a +4 bonus.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'df514239-9034-42bb-a3aa-b2013ab0a8bd',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Meat Shield',
  'As an interrupt when a nearby ally takes Wound Points, spend 1 Fortune to take those Wound Points, and a Mark of Death, yourself. If the hit would have taken the ally above 35 Wound Points, take two Marks of Death.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0fc66d00-f116-4c65-97c7-2a12e10b36c8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Dammit!',
  'On your next attack after your client takes Wound Points, gain +2 Attack against the character who dealt the Damage.',
  'Bodyguard',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '886e11ad-25c8-43b7-ab12-01eea361f6d9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Client',
  'At the beginning of any fight, designate any PC or GMC as your client, who you will go on to protect. Spend 1 Fortune when your client takes Damage to reduce the Damage to 0. You take 7 Wound Points.',
  'Bodyguard',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '214d9800-a219-4645-9d90-771005a91bc3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Due Diligence',
  'The quarry’s first attack against you in this fight automatically fails.',
  'Bounty Hunter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '44f846a8-4394-4bc1-b4bb-0dc4828500c7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Quarry',
  'At the beginning of a fight, designate one enemy as your quarry. If the plot has already established that you’re hunting an enemy who appears in the fight, that character automatically becomes the quarry.',
  'Bounty Hunter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b6481303-fade-46ec-8823-601c0496e6c9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Share the Homework',
  'Spend X Fortune; that many allies of your choice gain +1 to attacks against the quarry until the end of the fight.',
  'Bounty Hunter',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '07b022b3-f718-4b32-a263-6ea553e667cc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rage Against Machines',
  'Spend 3 shots and make a Creature Powers attack, at close or ranged distance, against the Driving value of a foe operating a moving vehicle. The vehicle takes 8 Condition Points. If the vehicle is involved in a Chase, it also takes 8 Chase Points, and is treated as if it has been rammed or sideswiped.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1251e85b-d6b0-4365-8a5d-1e479540c75b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Monstrous Foot Stomp',
  'Momentarily grow a devastating pedal extremity. After you undergo a Transformation (q.v.) from human to creature, your next Creature Powers attack check this fight gets a free Fortune die. If successful, roll yet another die and add it to the Smackdown.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '191828ee-5492-48ff-b854-a0208012e505',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Schooled in the Hell of piercing',
  'Your attacks treat foes with Toughness ratings of 7 or more as if they had a Toughness of 5.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2d10c238-99d9-4ac0-bf18-a0f28597b8f4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Venom Sac',
  'When you hit a named character with a close combat Creature Powers attack, you may specify that they take no damage now, but instead take the damage from your attack +5, 5 shots from now.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '34d89f18-3e75-4b2d-813f-649be583f584',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Natural Weapon',
  'You strike with spines, claws, jagged teeth, or another monstrous body part of your choice. +2 Damage when making close Creature Powers attacks.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '551b4f7f-cd27-49b9-866b-73b4764de3d1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Death Resistance III',
  'Add +4 bonus to Death Checks.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '76896740-d867-4932-8c18-fd3c08efa428',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Foul Spew',
  'Barf acidic chunks on those who cross you. As an interrupt after you take more than 5 Wound Points from an enemy attack, spend 1 Magic and 1 shot. Enemy loses 3 Speed until end of fight if this is the first sequence, 2 Speed if this is the second sequence, or 1 Speed if this any subsequent sequence.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9a160c1c-2e6e-4a6d-bd44-4a8d2ce76c5e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Steel Hide',
  '+3 Toughness vs. ranged attacks during the first sequence of a fight, +2 during the second, and +1 during the third.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'b19866f5-3268-4f85-a6ab-292d1da65a7e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Blood Drain',
  'You have a specialized body feature that allows you to draw blood from living victims. Examples might include hollow fangs, rasping mouths on the palms of your hands, or dozens of little suckers on your torso.  After dealing Wound Points to an enemy, spend 1 Magic and 1 shot as an interrupt. Subtract the number of Wound Points you just dealt to the foe from your own Wound Point total.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bb44fe57-5611-4419-88be-7c7453a11527',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Courtier of the Yama Kings',
  'Spend 1 Magic to seem trustworthy to all authority figures present in the current scene. Lasts until end of adventure, or until you actively violate their trust, whichever comes first.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c61e9037-cddf-4917-b802-e9822f14ae19',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Transformation I',
  'You may change back and forth from your true form to that of an ordinary-looking human being. Describe the single human form you can assume. While in this form you can’t access your other Creature Powers. In combat, it takes you 3 shots to transform. In any other scene, it takes about 20 seconds.  If you are a ghost, your normal-seeming false form looks like you, except for the dead and see-through part.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'ca2e303c-dc21-467f-b36c-ae3f209db04c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Insubstantial',
  'Pass through solid matter by checking Creature Power against a Difficulty of 1 for each inch of material you are moving through. Specify two types of matter you cannot pass through; your GM picks a third.. Note that this power does not make you immune to damage.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cec64a3a-2e2a-4f4f-a520-0a13b25227a7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flashback from the Hell of Knives',
  'When a foe downs a hero, and is close enough for you to attack, make an attack against that foe as an interrupt.',
  'Creature',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '0beeb798-f978-4a98-9222-eefd8c54c37a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bag Full of Guns IV',
  'Start each fight with a revolver (9/2/6). After each attack, spend 0 shots to move to the next item in this gun list: Colt 1911A (10/2/4), Desert Eagle .357 Magnum (11/3/3), Chiappa Rhino (12/3/5), Mossberg Special Purpose (13/5/4), homemade shotgun (14/5/4), homemade rifle (15/5/1), homemade rocket launcher (16/5/4), homemade shoulder-mounted Gatling (17/5/1), homemade shoulder-mounted laser Gatling (18/5/1), homemade quantum collapser mini-Derringer (19/2/3). Homemade weapons fall apart at end of fight. Only you can use them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3ee4a4d8-4e53-4a2e-8cd2-96573b3b0e93',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Both Guns Blazing III',
  'Fire two guns simultaneously at your opponent; these must be handguns or otherwise outfitted with a pistol grip. Treat as one attack, with the Damage Values of both guns added together, and the opponent’s Toughness doubled.  Make one Reload Check for both your guns; one reload action reloads both of them.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '44b2a669-ec42-4675-9de5-2b4379598a6b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Battle Scavenge III',
  'You gain +4 to Rearm Checks.  You may respond to a failed Reload Check by arming yourself with the weapon formerly carried by a fallen gun-wielding opponent. You may choose the best dropped opponent weapon that has not already been picked up. This action costs you 0 shots and allows you to carefully replace your previous weapon. You gain a free Fortune die on your first attack with the scavenged weapon, and regain 3 spent Fortune points.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3ea15c7d-274f-4efb-9351-b4e995b58d7c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Very Big',
  'You make Up Checks and gain Marks of Death only when you reach 50 Wound Points. Impairment of –1 occurs only at 40 Wound Points; Impairment of –2 at 45 Wound Points.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '6a9ac331-2ebe-4ed5-b78d-96c9714efd07',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Healthy as a Horse I',
  'You get a +3 bonus to Constitution Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f9a19937-d229-4cba-8926-ac0da7ce8959',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Internal Lockbox',
  'An artificial cavity in your abdomen allows you to store stuff where ordinary searches can’t find it.  A single gun with a Concealment of less than 5 is considered to have a Concealment of 0, until you remove it from your lockbox.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7d16058e-ddb9-4792-8ed5-eb4c54a60c9e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Strong as an Ox II',
  'You get +4 to all Strength Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'fea7b159-c27c-4291-a625-5d108a869ee5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fluid Spill',
  'If, when you are Impaired, an enemy misses you in close combat, spend 1 Fortune as an interrupt to attack that enemy.  This models a surprise opportunity you get when your opponent slips on the fluid you’re leaking.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '7f18c2fa-26f1-43cd-9a53-e89955412821',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mounting Fury IV',
  'As Mounting Fury II, but your Damage Bonus is +3.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '96240583-95fe-490c-8724-5a9f953910e3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Strong as an Ox I',
  'Add 3 to your Damage on any successful Martial Arts strike, including strikes with hand-to-hand weapons. (Damage Values for your starting weapons already include this bonus.) You can use absurdly large objects, like motorcycles, as improvised weapons. You also get +3 to all Strength Checks.',
  'Big Bruiser',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2b9f780e-115c-46ce-917a-2a7f57eae922',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ghost Sense',
  'Ghosts capable of acting on the physical world, like the ones represented by the Ghost archetype, are rare. Ordinary ghosts, trapped in spirit form between this world and the next, mindlessly repeating moments from their living days, swarm through every place where people have lived and died.  Spend 1 Magic to see the ghosts all around you in a single scene. Unless you count the odd grotesque transformation or ineffective lunge in your direction, they can’t really communicate with you. But their presence and appearance may provide clues to past events in the area. Densely populated areas always crawl with ghosts. No refunds on Magic points, even if you see no ghosts or none of them can help you.  Ordinary supporting characters sometimes develop this sense spontaneously, without knowing the first thing about sorcery. They may be victims of curses or physical trauma. Some received tissue transplants from dead donors who have become restless ghosts. They react to their new sense with understandable terror, and can’t choose when they see ghosts.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '51f05a48-eced-4cb9-8d23-273a4fd41c2b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Intra-reality Goggles',
  'Identify all Innerwalkers in your direct line of sight within 300 m. For Innerwalkers within 15 m, the goggle read-out tells you which other juncture they last visited and how long ago they left it.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '61fc611d-837c-48a7-86ce-05ee6fd1a820',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Grav Plate',
  'Make a Scroungetech attack against multiple opponents. If successful, all of your targets take 0 Wound Points but lose 3 shots apiece.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '64a9fd28-2b4c-41b2-803f-905b37039f31',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tracker Pin',
  'Once you hit a foe in close combat, you subsequently know precise coordinates of the foe’s whereabouts at all times, provided the two of you are in the same juncture. This works for the duration of the series.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'd272e57e-e9cf-47e1-b176-7aca9d703ad3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Schrödinger Circuit',
  'As an interrupt before making an Up Check, swap Wound Point totals with a willing ally. Ally does not have to make an Up Check until next taking Wound Points and gains a +2 bonus on that Up Check.',
  'Scroungetech',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '30d7aa76-33b1-482f-9da5-f74273f8f6c9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Illusion',
  'Spend 1 Magic to make one object or person look, smell, and sound like something else of roughly the same size and physical configuration until end of scene. Or create an illusion from thin air, registering to sight, smell, and hearing, but not to touch or taste. Characters encountering the illusion make Notice Checks to identify it as false; if successful, they know something weird or magical is going on. Sorcerers with at least 1 Divination schtick get a +5 bonus to their Notice Checks.  Illusions affect characters’ responses during story scenes but not in combat. During a fight they may not consciously twig to the false vision, but happen to make decisions allowing them to conduct themselves effectively.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '473d60a8-8efb-467a-8c46-6d9a8c47a94e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sustained Domination',
  'Spend 1 Magic and make a Sorcery Check with a creature’s Will Resistance value as the Difficulty. The creature will obey your spoken instructions for a number of hours equal to your Outcome, or until end of session, whichever comes sooner. It will not fight for you but will otherwise obey the letter of your instructions to the best of its abilities. Does not work on bosses or uber-bosses.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '52997eee-7e8b-4969-b3ab-715c097dc183',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Prediction',
  'Spend 1 Magic to gain good, if somewhat obscure, advice or information about the future.  Most traditional Chinese mages employ the I Ching (pronounced yee jing), the ancient Book of Changes. You perform the divination by using an apparently random method to select one of its 64 cryptic verses, or hexagrams. The traditional method of invoking randomness has the user dividing yarrow stalks into odd and even clusters, arriving at a pair of trigrams. Trigrams are parallel broken or unbroken lines arranged in threes. Add the two trigrams together and you’ve got your hexagram. Example hexagrams include “Coupling,” “Diminishing,” or “The Well.” The real art comes in connecting the enigmatic verse and its other symbolic associations to the question you’re posing.  Even more traditional mages tell fortunes by throwing tortoise shells into the fire and then interpreting the patterns of cracks that appear on them after they are burned.  The GM provides a cryptic answer to a question posed by the sorcerer. This answer makes the player work to puzzle out its meaning and moves the plot along by providing a clue that gets the characters to the next scene.  If the GM is familiar with I Ching she can choose in advance an applicable hexagram.  If the attempt fails, the sorcerer gets a random hexagram instead. (The I Ching being what it is, the players may well find just as good advice in the random hexagram!)',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '678bc0f7-e0fd-4042-b859-a006f1ba9c7a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Conjured Blade',
  'You create a handheld blade of magical force and wade into hand-to-hand combat. As per Chi Blast, but doesn’t count as a ranged attack, and so is useful against an opponent whose schticks somehow thwart ranged attacks.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '9f63a6b3-d85a-42cf-95f1-7235bac24739',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Invocation',
  'Spend 2 Magic to seize a particular creature through time and space and cause it to appear at your side. You can target a creature if you successfully used Domination against it in the past, or if you have on your person a former body part of the creature, such as a claw, piece of hair, scraping of skin, or severed hand. Requires a Sorcery Check against the creature’s Will Resistance value; on a failure, nothing happens and you get the Magic points back. Merely summoning a creature does not ensure its cooperation. In fact, in most cases guarantees your subject’s extreme displeasure.  You can invoke hero ghosts or supernatural creatures, but only if their players want it to happen. If they do, your attempt automatically succeeds and costs you nothing. ',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'bae7ba99-0534-4064-8c2c-9a8461a95bc0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heal Object',
  'Make a Sorcery Check to restore a damaged inanimate object to its original condition, using Difficulties suggested by the table below. GMs set Difficulties for unlisted items, with larger objects being harder than small ones, and complicated devices harder than simple ones. You get one try to heal any particular given object, ever.  
 Due to the well-known mystical principle of, I dunno, uh, transitive numinosity, vehicle healing is its own separate schtick, below. You can’t heal vehicles with Heal Object.
 Healing Object Difficulty: Book or paper document 9, Computing device 10, Door 5, Gun 10, Hut 7, Martial arts weapon 7, Office tower 20, Small house 15',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'f42d5c6e-f939-42ea-9f1c-55c9e7781413',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Immortality',
  'The quest for immortality occupies a central position in Chinese magical lore.  Spend 5 Magic to reverse a year’s worth of aging in any target. If spent in the second half of a game session, your Magic does not reset at the beginning of the next session.  Most often used as an inducement to get powerful, elderly people — sometimes kept alive only by such magics — to aid you.  Chinese mythology inextricably associates sorcery with the pursuit of immortality. Boss sorcerers’ evil schemes may revolve around cracking its secrets. It’s not much use to action movie heroes, though. Accordingly, you get this schtick for free the first time you acquire another Heal schtick as an advancement.',
  'Sorcery',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '2c84b489-35a7-4d87-807d-5a2fbc88bf43',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Integrated Training',
  'Add +1 to Guns if your previous attack used Martial Arts. Add +1 to Martial Arts if your previous attack used Guns.',
  'Spy',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '039ae7b9-33dc-4585-b0d1-e71cfa422191',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Nunchaku Nunchaku Nunchaku',
  'When a Martial Arts nunchaku attack hits a named character, spend 1 Chi. Your nunchaku Damage Value increases by 2. Until the end of the fight, each additional successful Martial Arts nunchaku attack increases your nunchaku damage by an additional 1.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '1630c04e-860f-49d2-9c7f-cf821ad4a72b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Pressure Block',
  'When an opponent misses you with a hand-to- hand attack, spend 1 Chi as an interrupt to give opponent a –1 attack penalty until end of fight. Not usable if opponent is already Pressure Blocked.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '26ea44a0-3e99-4c53-b53d-a262b17cb4e0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Target the Core',
  'Spend 1 Chi as an interrupt after making a successful unarmed Martial Arts attack. Until the next keyframe, the target is at –1 Defense vs. Martial Arts attacks.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3b5df6ed-7d41-46d4-9ff9-163cbc57b04f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Shelter of Darkness',
  'Summon a cloud of unnatural darkness to shroud your allies from harm in combat. Spend 3 shots to grant a Defense boost to all of your allies, which you may augment with Fortune. When an ally takes Wound Points from an attack while benefiting from this boost, you may, as a 0-shot interrupt, attack the ally’s attacker.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3eea98c2-a5f3-42c2-aec6-ae1e8b3ed6ea',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Training Sequence II',
  'Add +1 to Defense vs. bosses; +3 Defense vs. uber- bosses.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '3f4735b5-4a92-4691-ad54-c58edbffcb38',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Lightning Fist',
  'When you hit an opponent with a Martial Arts punch attack, spend 1 Chi and 1 shot as an interrupt. For this attack, and until the next keyframe, your target’s Toughness is halved (round fractions up).',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'c4d0682e-a75e-4aae-8a93-e4b96574f347',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rise of the Downtrodden',
  'Spend 1 Chi and 1 shot as an interrupt when struck by an attack. Until the end of the fight, the base Damage Value of the weapon hitting you becomes the base Damage Value of your hand-to-hand weapon.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'cfe65ab7-0323-4f86-8ca6-37c46614e94c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Spear Push',
  'When you switch from another weapon to a spear, gain +3 Defense until the next keyframe. This bonus can’t be combined with Dodge.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dc65de39-2a42-465e-abe9-36bc3e4a3534',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Fire Cloak',
  'Flood the surrounding area with flame to create a hostile fighting environment for your foes. On a successful Martial Arts attack against an opponent whose Defense Value exceeds your Attack Value, the fight location suffers the adverse condition Extreme Heat until the next keyframe.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '8b725418-05b6-4540-ac3e-efb6375d8fbe',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mocking Arrow',
  'As an interrupt when an ally gets a Way-Awful Failure on a Guns attack, spend 1 shot to make a bow attack against the target of that attack.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  'dc2e8c6b-442b-48e7-831d-feca1ea34f96',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Showy Arrow II',
  'As an interrupt when an ally hits with a Guns attack, spend 1 Fortune and 2 shots to make a +1 Guns attack with bow and arrow against the same target.',
  'Guns',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '019d0ca0-cfa9-4918-af05-80797d4a0081',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Contagion',
  'Suitable for: Supernatural Creature.  After the foe does 1 or more Wound Points on a successful Bite attack, the victim makes a Defense Check against the foe’s attack result. On a failure, the victim begins to turn into a version of the foe, and takes 1 Impairment until end of fight.  Only one hero per fight suffers the Contagion effect.  After the fight, the victim falls into a sickened, semi-conscious state. It can be ended, and the contagion cured, with an expenditure of 3 Magic points by a character with any schtick from the Sorcery Heal specialty. This expenditure cures any number of victims. Absent this intervention, the group becomes aware of a cure that requires them to take action in the storyline. They incur a debt or negative consequence to get or administer the cure.  The cure for the key jiangshi’s contagion effect draws on common folklore and is found in that foe’s description on p. 194.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '70900921-99c5-4e7a-9e68-979652c77873',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Flying Guillotine',
  'Suitable for: Martial Artist.  The foe hurls a bladed collar, sometimes connected by a chain, sometimes thrown by a weird curved blade, onto a victim. Soon blades will pop from the collar and it will constrict with decapitating force.  On a successful Martial Arts ranged hit, note the Wound Points hero would suffer on a Smackdown calculated with a Damage Value of 20. Unless another hero makes a successful stunt attack or athletic stunt to remove the collar within the next 3 shots, the hero suffers that damage.  Usable once per sequence.',
  'Foe',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '4fb60739-6913-457d-a319-dafe60e63038',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Stillness',
  'Add +2 Defense if you have yet to attack during the current sequence.',
  'Transformed Animal',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO schticks (
  id, campaign_id, name, description, category,
  created_at, updated_at
) VALUES (
  '86c5286a-3096-4563-9d0b-0dfa6f835b3c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Signature Weapon',
  'Select one specific martial arts weapon as a signature weapon. Your character might wield his lucky combat knife, the sword that got his father through a war, the hallowed spear of his destroyed village, and so on. A character using a signature weapon gets a +3 Damage Value bonus with that particular weapon. Note that this applies to a single, actual weapon, not to all identical weapons; your wing chun butterfly sword gives you a +3, but none of the other identical copies hanging on the dojo wall do. GM guidance for Signature Weapons appears on p. 302.',
  'Martial Arts',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'e8bfe10b-64da-4fb1-ba2f-541649e907d2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rossi Model 851',
  9,
  2,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '079c9fc3-979a-4c06-a24a-e5a85e2dea3f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'TDI Vector',
  11,
  5,
  2,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '07ea8ecb-f3e9-4c31-8c95-6b0397db6c56',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Beretta Model 950BS Jet Fire',
  8,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '66c1a79c-a70c-4416-85c9-763c5baa4bb0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heckler & Koch P7',
  10,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '72ae8aaf-c078-48e6-95d7-f0c5925864ca',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ruger Red Label',
  10,
  5,
  6,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '95ba6853-0f66-46dc-a443-2d7019af7f65',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Kahr K9  ',
  10,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '97577966-4664-46ca-a5b9-318ba01725a5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Colt Delta Elite Mk IV Series 80',
  11,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'de55fd8f-7247-4ece-a347-24731b43c32d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Hechler & Koch MP5',
  10,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '9525033d-893a-44bb-af6d-1656666f2590',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heckler & Koch MP5 K',
  10,
  3,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'bfb32e5a-3f32-4390-a480-18ff1a24534c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Colt M6351',
  10,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '5c9bc1ec-f933-44c1-b4db-785aefbb1c3f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sig-Sauer P220',
  10,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '873b804f-1494-4c5e-9886-3099732761c1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Desert Eagle .50AE',
  12,
  3,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '7686ea35-1396-4ff3-9ed9-0a2f801db604',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'S&W Model 19 Combat Magnum',
  11,
  2,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'c7f67a85-a730-406a-b021-8f8431ed3cc8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'M3',
  10,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '7487e8c6-be77-4bea-80b1-d53970136717',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Beretta Model 21 Bobcat',
  8,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '373265f1-472f-4d73-aa59-52c6d31e3767',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Chiappa Rhino',
  12,
  3,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '37b23943-3d4f-4079-b818-f993b52165aa',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'MP40',
  10,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '1bfde76a-b25d-4308-8abd-caafd9516862',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'FN F2000',
  13,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '516af5e5-2094-4771-96c0-bf0813befbe9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Colt King Cobra',
  11,
  3,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '2d9d2370-2824-41fc-bfcf-feb84a265230',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Thompson Center Arms Contender',
  12,
  3,
  7,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '896d34cd-fe9d-44a3-bc79-f66de2e42e3e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Smoke Pellets',
  0,
  0,
  0,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'e382cec9-3b64-4f42-b9df-98b05c7f2ff5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'SVD Dragunov',
  13,
  5,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '5d3ed52a-9a89-43d7-a6b9-3d5d3934a441',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Norinco Tokarev',
  10,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '9afbea98-a753-452d-8ae5-ec16e03fe2a1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Benelli 90 M3',
  13,
  5,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '7118a566-bf72-4697-bff3-7d9f73e1dfc6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Winchester Model 1300 Marine',
  13,
  5,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '36e7913d-b2d0-43a9-93c2-18e452bb775d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ghost Guns',
  14,
  0,
  0,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '0c7cdc1c-e51e-43b5-8b1c-6fba06edd3e7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bernardelli',
  13,
  5,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '89e3ea66-bd13-4ed5-943b-fa5c1ac95a03',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Rossi Model 515',
  8,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '78bb427a-d5c2-4937-a4d2-12dfee5a16f9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Throwing Star',
  5,
  0,
  0,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '2f406acf-9d8c-42c1-bc8f-ed5983ee30d7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Taurus Model 85',
  9,
  2,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '55b72511-b4d0-4c42-9e10-6f8663c398ec',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Beretta 1201 Riot',
  13,
  5,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '10036f39-02ea-4c3a-a2b1-acd0607bea77',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'AK-74 Assault Rifle',
  13,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'c741e291-fba5-462a-bf02-545f2c18f404',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Beretta 92FS Centurion',
  10,
  2,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '4be7167d-e063-4ce3-bea2-2d6cf77e92b1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Benelli 121',
  13,
  5,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '3e3cc598-0bda-4ca6-90b4-7e7d0e06aff6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'AK-47 Assault Rifle',
  13,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '9ca5c7d2-ad6c-4850-9916-3571a5b2c8e0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Smith & Wesson 2213 Sportsman',
  8,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'd54105a3-830a-4516-823a-d7e8e4aee168',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bow and Arrow',
  7,
  5,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '15effb28-cd54-43f4-a7f5-17776339c3dc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heckler & Koch HK45C',
  10,
  2,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'ec3d08d2-5709-4357-9735-47e1cc0b6910',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Winchester Model 70',
  12,
  5,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'd2e3bd8a-43ce-4a13-b9d1-bb369482f8ae',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Glock 17  ',
  10,
  1,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'ae901570-617d-4d44-a2c9-21241cc0e7a9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Llama Large Frame',
  10,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '5a637104-de5a-4cf9-a145-306e36dbaf1a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Norinco Type M1911',
  10,
  3,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'b45ac88d-9829-4f11-b34a-72bf0354425c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Colt Detective Special',
  9,
  1,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'e95cf13d-6e13-4fd9-ac6c-b9c774e43690',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ruger MP9',
  10,
  3,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '5f240d4d-1fc4-48ba-aa5a-73d7aa64f2fc',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Kimber Solo Carry',
  10,
  1,
  6,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '84f5e13b-50d9-46b2-93b1-7b8fb6355b77',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Franchi SpAS-12',
  13,
  5,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'b88dbf74-7cc6-4e1d-91de-c80d99053ebf',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Colt 380 Gov''t Pocketlite',
  8,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Kusarigama',
  10,
  1,
  0,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'd7936c11-b97c-4231-81f2-fde59e983b82',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Thompson M1A1',
  10,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'cb137dc3-3a14-465b-938c-4512e6f7b6a8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Amsel Striker Combat Shotgun',
  13,
  4,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'b2bb30b9-dca5-4bf9-8400-3f34f5f6eeb1',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heckler & Koch MP7',
  12,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '92a0c1f7-aafe-4ca7-ba58-162f9c9ffc7a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mossberg Special Purpose',
  13,
  5,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'c1713b6e-e936-4759-b497-3898f08ed866',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Walther P5 Compact',
  10,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'e4ced9eb-5b92-48f4-8b99-0683ac0bf3ca',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Intratec Tec-9',
  10,
  3,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'c7ceb674-61b1-42cb-ac7b-4998e1557227',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heckler & Koch UMP',
  11,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '87f5de49-868e-4215-ad15-4f49e21d7559',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Uzi',
  10,
  4,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'e1e3049e-114b-4839-8e02-3ba14b38195c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Intratec Tec-22',
  8,
  2,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'cbec11ae-1310-4626-bced-87c7502ae7a2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Beretta M9',
  10,
  2,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '7a484608-1eaa-420f-a8cf-5bc3b6470782',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Heckler & Koch MP5 Police',
  11,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '6a0df37e-a310-4c5b-bfca-79ba8796732f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ruger P89',
  10,
  2,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '8cc4d4cd-0beb-48ed-84c3-1ccbf660b175',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mini Uzi',
  10,
  3,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '1c454ba1-f55a-4139-bd1d-40db99bbc439',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ninjato',
  9,
  4,
  0,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '4b337cb9-316a-4edb-bd17-82f8d476ce13',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Walther PPK',
  9,
  1,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '805ce45c-2d13-4fdf-aaff-19ab6a57e020',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Glock 18',
  10,
  2,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'd11a3083-685f-489e-af4e-99b7acad601f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Grendel P-12',
  9,
  1,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '23762dd8-9deb-4f06-8bf4-37f7a0373d0b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'E.T. "Series One Laseraim"',
  11,
  3,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'a2f51c44-971c-429d-8bfe-88037eefa31d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'CZ 75B',
  10,
  1,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '76be2025-3d1e-4caf-a027-37a33bb27c6d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Smith & Wesson Sigma',
  10,
  1,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '8622b60b-e73e-4f44-954e-c9db554610f9',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'AMT Automag V',
  12,
  3,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'b90971ba-686d-47a2-9972-b34c97217f3e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sig-Sauer P230',
  9,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '67ab6c08-84e8-498c-871e-fd403a1cdcff',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Colt 1911A',
  10,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '96217554-4aa6-4906-8249-b2063d03a0e3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Smith & Wesson Model 500',
  12,
  3,
  5,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'bc78df58-71b4-44ce-b03f-f77998a1049c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'M14',
  13,
  5,
  2,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'cc3a4cfa-979b-4817-b669-f22864106e37',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Daewoo K2',
  13,
  4,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '6b28ce0f-7feb-48b5-9b0f-5a4c3c3e7495',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Remington 870 Police',
  13,
  5,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'a2d3a510-142e-4039-a4bd-491ee82e7c84',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Tavor Tar-21',
  13,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '41abac95-bc86-401f-b49d-8b3fa5f80236',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Browning Hi-Power',
  10,
  2,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '97e452ab-e8a6-49c1-8e47-3c85ae3f0464',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Desert Eagle .357 Magnum',
  11,
  3,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'cf812427-8794-4307-8554-0e36498a7815',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'M16',
  13,
  5,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '056ac3f7-1e54-468f-aa6a-3da4c0e0bf7b',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Beretta M12 Submachinegun',
  10,
  5,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '0e5f74d8-c360-42bd-8bba-4c832f4dadb4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Makarov',
  10,
  2,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '1009c582-2e3a-4695-99ef-23a83c97f832',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'FN P90',
  13,
  5,
  6,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '82ed94c7-2a57-4511-beb7-f97cb5d4f82f',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Grendel P-30',
  8,
  1,
  1,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '3f822c85-aace-4c48-803d-f882cfec75bf',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Smith & Wesson 3566',
  11,
  3,
  3,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  'fe9d584a-74fa-4059-870e-6b8efc7c97f4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'American Derringer Mini-Cop',
  11,
  1,
  6,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO weapons (
  id, campaign_id, name, damage, concealment, reload_value,
  created_at, updated_at
) VALUES (
  '469d09ac-586d-4d80-9a3b-fa7ea4c78a8d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Auto-Ordnance Pit Bull',
  10,
  1,
  4,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/The_Dragons_e8XI4PLDS.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  '6bc3abe7-2890-432f-a397-89c763f54d18',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Dragons',
  '<p>The perennial underdogs of the Chi War, constantly rising from humble origins to fight for freedom and justice. Founded by heroes like Kar Fai and the Prof, they recruit everyday heroes, maverick cops, martial artists, and masked avengers who believe in protecting ordinary people. They have a tendency to get wiped out and need constant replacement, but their cause - defending the little guy against overwhelming odds - ensures new generations always answer the call.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/The_Guiding_Hand_PsAEzSyKyF.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'c52de513-622e-4bda-a88e-cec2a5c13ddb',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Guiding Hand',
  '<p>Traditional Chinese monks and martial artists fighting to preserve their civilization against foreign corruption. Founded in 1810 by politically minded monks who foresaw China''s decline, they use spiritual wisdom, kung fu mastery, and feng shui knowledge to resist colonial powers and maintain traditional values. Led by Perfect Master Quan Lo, they operate through Golden Candle Societies, combining ancient martial arts with patriotic resistance.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/The_New_Simian_Army_v4lQcL3mI.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  '9afef0d9-233c-4696-b237-aed0515e0500',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The New Simian Army',
  '<p>A militant faction of cyber-enhanced apes led by Furious George, who broke away from the Jammers after the C-Bomb''s detonation. Believing that the extinction of humanity was evolution''s plan, they see themselves as the rightful inheritors of Earth. Unlike the guilt-ridden Battlechimp Potemkin, Furious George views the C-Bomb as divine providence and leads his simian supremacist army to complete what he sees as natural selection''s work.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Eaters_of_the_Lotus_NuQyPRoSS.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  '8a2a13dc-447f-4e71-98fd-732c8d65be78',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Eaters of the Lotus',
  '<p>Corrupt eunuch sorcerers who have manipulated Chinese imperial courts for millennia. These pale, long-fingernailed court officials use dark magic to accumulate power behind the throne, commanding demons and evil spirits while presenting themselves as loyal servants. They infest periods of weak imperial rule, twisting policy through their intermediary positions between emperors and outside officials, always seeking to expand their supernatural influence.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/The_Jammers_k-5iq_chse.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  '50a7bc5c-ca36-48b7-a17b-5698c2e1958e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Jammers',
  '<p>Anarchist rebels who destroyed the Future juncture by detonating a Chi Bomb to eliminate all magic and free humanity from supernatural control. These scrappy revolutionaries, originally led by cyber-apes Battlechimp Potemkin and Furious George, believed that feng shui sites allowed totalitarian control over people''s minds and identities. Though their bomb had catastrophic consequences, they maintain that destroying chi was necessary to preserve free will.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/General_Grundle_NEVqZeL4y6.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'd12ebf38-6bf4-485d-ab01-36e71e99306a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Grundle''s Wasteland Empire',
  '<p>The cyborg warlord General Grundle rules the post-apocalyptic Future through control of fuel, weapons, and technology. From his massive mechanical throne, this grotesquely obese dictator commands road warriors, scavenger gangs, and anyone desperate enough to serve him for gasoline and protection. His empire is built on the ruins of civilization, where survival depends on automotive warfare and allegiance to the only authority left standing in the wasteland.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Huan_Ken_oO2XgzfM4.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'c2c5b7cc-0c64-4866-97c1-b1c9b0e8c457',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Thunder Pagoda',
  '<p>The Thunder Monarch leads a twisted religious order that combines demonic power with corrupted divine authority. His followers are fanatical zealots who believe their master is the true voice of heaven, speaking through storms and lightning. Operating from gothic cathedral-fortresses in the Netherworld, they conduct blasphemous ceremonies mixing sacred rituals with supernatural horror. Huan Ken''s faction aims to establish a theocracy where his word is divine law, using fear and religious fervor to control both supernatural beings and any mortals they encounter.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Pui_Ti_1eLMqsaBq.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'ce40d0a1-ed7c-4122-a219-996e46425115',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Ice Pagoda',
  '<p>The Ice Monarch rules an elegant but merciless court of crystalline beauty and absolute cold. Her followers are aristocratic sorcerers who value perfection, order, and the preservation of power through unchanging hierarchy. From palaces of living ice, they practice subtle manipulation and patient scheming, believing that true power comes from patience and precision rather than brute force. Pi Tui''s faction seeks to impose their vision of perfect order on the chaotic world, creating a realm where everything has its proper place and nothing ever changes without their permission.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Li_Ting_6_B2GDJVnc.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'f1b59811-a684-4d3f-a07b-4fcafc79eb7d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Fire Pagoda',
  '<p>The Fire Monarch commands legions of flame-wielding sorcerers and fire elementals across the scorched realms of the Netherworld. His followers worship him as the incarnation of destructive power, believing that only through burning away the old can the new be born. Li Ting''s domain features volcanic fortresses and cities of molten glass, where his servants forge weapons from living flame and conduct rituals in rivers of lava. His faction seeks to return to the earthly realm to purify it through cleansing fire, viewing the current world as corrupt and in need of renewal through destruction.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Ming_Yi_jf1YDThyM.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  '954edb9f-afd2-4df8-985d-6756594d0d94',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Darkness Pagoda',
  '<p>The Darkness Monarch commands a secretive network of spies, assassins, and occult scholars who operate from hidden temples throughout the Netherworld''s darkest corners. Her followers master the arts of stealth, information gathering, and striking from shadows, believing that knowledge and secrecy are the ultimate weapons. They conduct their operations through a web of cults and secret societies, infiltrating other factions and gathering intelligence for their mistress. Ming I''s faction aims to control the world through information and fear, ruling from the shadows while others fight openly for power.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Manlysaka_q3TJn-6_G.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'c44f7eaf-425b-497f-b278-92a3bc612e55',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Manlysaka',
  '<p>A ruthless techno-corporate empire that promotes cybernetic supremacy through economic manipulation, technological addiction, and systematic discrimination against unenhanced humans. Led by the cyborg executive Ma Yujun, Manlysaka operates on the philosophy that human evolution requires the abandonment of biological weakness in favor of mechanical perfection, using their monopoly on cybernetic technology to create a society where augmentation is both carrot and stick. The corporation maintains control through vertical integration - they manufacture the implants, provide the financing, control the job market that requires them, and own the medical facilities that install them, creating a closed loop where citizens must literally buy their way into the new cybernetic aristocracy or face permanent underclass status. Manlysaka''s agents include enhanced corporate security forces, executive cyborgs with neural-linked management capabilities, and street-level enforcers who hunt down "purist" resistance movements, all united by their belief that Ma Yujun''s vision of a post-human future represents the next step in evolution rather than the corporate enslavement of the human soul.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/The_Ascended_Zx6uYB_koM.png
INSERT INTO factions (
  id, campaign_id, name, description,
  active, created_at, updated_at
) VALUES (
  'f9c89687-9813-4c50-98fb-ceecfcc5e335',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'The Ascended',
  '<p>A secret society of transformed animals who have ruled the world from the shadows for centuries. Originally animals who magically became human in ancient times, their descendants now control governments, corporations, and media worldwide. They maintain power by controlling feng shui sites to keep magic suppressed - if magic returns, they risk reverting to their animal forms. Most members are ordinary humans unaware of the conspiracy, but the inner circles (the Pledged and the Lodge) know they serve mysterious masters with inhuman heritage.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Martial_Artist_wm6oQXDYi.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Martial Artist',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"An accomplished young student of one or more schools of hand-to-hand combat, you are as effective with your bare hands as when wielding traditional hand-to-hand weapons. Embarking on a lifetime\u0026#8217;s study, you have lately mastered a number of esoteric chi powers. Most importantly, you have absorbed a profound truth: martial arts are more than just a series of combat moves. They represent an ancient and learned discipline, one that preaches restraint, discipline, and humility. You work hard to live up to that philosophy. You choose your fights carefully, and work to uphold the values you have learned, such as reverence for elders, respect for the traditions of the past, and self-sacrifice for the greater good. You probably work at a humble job, caring little for material goods. The only goal you consider worthy of pursuing is the physical and spiritual perfection attained by the great masters of the past. When you encounter the outlines of the chi war, your dedication to honor and self-perfection leads you into the battle against evil without a second thought.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":8,"Sorcery":0,"Creature":0,"Archetype":"Martial Artist","Toughness":8,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":8,"Martial Arts":15,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":11,"Constituion":0,"Intimidation":0,"Info: Eastern Philosophy":11}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Redeemed_Pirate_Si_t1NuWW.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'bcf03792-c296-48d8-baa8-d96261089571',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Redeemed Pirate',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You used to be a member of one of the many pirate gangs that sailed the South China Sea. The sea belonged to you and your comrades and there wasn\u0026#8217;t a thing the Manchus could do about it. You lived a heedless live of looting and slaying. When the British feet arrived in Chinese waters and took it upon themselves to end piracy, matters grew dicier for you and your friends. Against these impudent foreigners, you did what you had to do to survive\u0026#8212;including some things you weren\u0026#8217;t proud of. Your efforts against the British brought you into contact with the monks of the Guiding Hand. From them, you learned of the chi war. Yet you bridled under their Buddhist purity. Detachment from earthly pleasures has never been your way. The pivotal events of your melodramatic hook sent you to wandering again, perhaps far from your time and the seas you where you feel most confident. Now you are about to throw in with a ragged band of misfits, in whose company you might finally redeem the darkness of your past.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Redeemed Pirate","Toughness":7,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":11,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":12,"Backup Attack: Guns":12,"Info: Seafaring and Piracy":15}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Spy_z5n_dxhRg.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'e95d3487-5ef2-478c-8035-b878c455e463',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Spy',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You used to work for an intelligence agency. There are any number of reasons why you might have left, melodramatic hooks all of them. Maybe you were squeezed out by the machinations of shady new superiors. (Did you overhear them saying something about a Lodge, or a Wheel?) Maybe you left under a cloud, after making a tragic mistake that led to the deaths of those under you. Or maybe you don\u0026#8217;t remember who you used to be and why those assassins keep chasing you, but are determined to find out. Your retirement, happy or otherwise, comes to an abrupt end when the shadow world closes in on you again\u0026#8212;this time revealing the strange outlines of the chi war. What it offers, more than the chance to put those mothballed skills back into the field, is a feeling that may be new to you\u0026#8212;that this time, you\u0026#8217;ll know why you\u0026#8217;re fighting, and that the fight is just.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Spy","Toughness":7,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":7,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":15,"Fix-It":11,"Notice":0,"Police":0,"Driving":0,"Gambling":12,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":12,"Seduction":13,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Fashion":15,"Info: Geopolitics":12,"Info: Food and Drink":14,"Backup Attack: Martial Arts":14}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Sword_Master_VYh1Vt2XZ.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sword Master',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Once you enjoyed status, respect, and honor, as a true warrior. You cared only for the practice field, for the art of the sword. You trained until your blade became an extension of your being. Only in those elongated split seconds when you dueled against a foe, when the time stolen for an intake of breath could mean the difference between life and death, did you feel truly alive.\r\rThat was a long time ago. Before you were betrayed, before you were forced to confront the emptiness of your warrior ethos. You might have believed it, but your superiors never did. And when the bad times came, they discarded you, without a second thought.\r\rSince then you\u0026#8217;ve wandered the earth, seeking a fight. Not a fight, the fight. The one that will once more give your life meaning.","Hair Color":"","Style of Dress":"","Melodramatic Hook":""}',
  '{"Guns":0,"Type":"PC","Speed":9,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Sword Master","Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":6,"Martial Arts":14,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":11,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":13,"Info: Smithing and Metallurgy":14}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Bodyguard_68rTwKZZ8.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bodyguard',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You have a very particular set of skills. As a Personal Protection Specialist, you get your client from point A to point C while avoiding the bad guy at point B. Obscure outside the tight circles of your profession, you avoid the glare of fame cast by your celebrity and political clients. Maybe you lost the client who most mattered to you, the one you broke the rules for and fell in love with. Perhaps your client has been taken by shadowy forces, and your entry into the chi wars comes as you swear to get her back. Now your greatest act of protection awaits, as you discover the chi wars and realize that the entire world needs a bodyguard.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":14,"Type":"PC","Speed":8,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Bodyguard","Toughness":6,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":7,"Martial Arts":12,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":"Martial Arts"}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":13,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Celebrities":12,"Info: World Leaders":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Transformed_Dragon_EyuLOBslUH.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'b1103cf5-a767-4ee3-aa18-4d914ec74f28',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Transformed Dragon',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"In Ancient days, animal spirits from the supernatural realm between being and non-being sometimes yearn for the vividness of mortal existence, and through innate magic assume human form. They face not only the dangers brought by strange and powerful human emotions, but the efforts of exorcist monks, who seek to strip them of their new identities, sending them howling back to the spirit world.\rSometime between then and the Past, transformed animals banded together to prevent them from doing this. By slowly leaching magic from the world, they made it much harder for exorcists and sorcerers to banish, control, or revert them to their old status as intelligent snakes, foxes, tortoises, spiders, and so on. Once established, this alliance sought to protect itself by amassing political power. By the 19th century, these so-called Ascended secretly rule the world, as they continue to do in Modern times.\r\rDepending on when you were born, you might have literally changed from an animal into a human, or have such an individual way back in your family lineage. You may or may not know any of the secretive transformed animals of the Ascended, who fight the geomantic battle to keep magic difficult in the Past and Modern eras. Somehow destiny throws you into the chi war not on their side, but with the anarchic, freedom-loving Dragons.\r\rPerhaps that\u0026#8217;s because you carry the blood of their namesake\u0026#8212;the mightiest of Chinese supernatural creatures, the dragon. Knowing, imperious, confident, you stride through humanity\u0026#8217;s ranks mantled in good fortune. Driven by your melodramatic hook, you\u0026#8217;re willing to risk all you\u0026#8217;ve achieved and accumulated for victory in the chi war.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Transformed Dragon","Toughness":7,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Guns":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Masked_Avenger_tPz4TLfL-.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Masked Avenger',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"For many years, you watched your society slowly sink into corruption. Crime runs rampant on the streets. Justice eludes the common man. Criminals are rewarded; victims, forgotten. The police and judiciary, hopelessly tainted or just plain unable to deal with the evil\u0026#8217;s rising tide, can\u0026#8217;t be trusted to do the job. The time for brooding is over. Seeking to strike fear into the hearts of evildoers, you have donned a distinctive, armored costume and identity-concealing mask to take the law into your own hands. You use your own uncompromising moral compass to find wrongdoers and beat the crap out of them. With your fierce fists and barking automatic pistols, you aim to turn back the clock and return to an age of justice. Although your abilities are formidable, you do not expect to transform society all on your own. Only when people stand up for themselves and take back their own streets will the criminals of the world truly quake in fear. Rhetoric aside, your mission may not be entirely altruistic: the Masked Avenger\u0026#8217;s melodramatic hook usually involves sworn vengeance of some sort. Did some terrible event that pushed you over the edge from thinking about vigilantism to stalking the streets in funny clothes looking for villains to punish? Maybe you\u0026#8217;re a little crazy\u0026#8212;but the really crazy ones are the bad guys who stand in your way.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Masked Avenger","Toughness":8,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":11,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":15,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":12,"Info: Science":15,"Backup Attack: Martial Arts":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Ninja_t0MQBmoN2.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ninja',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"If you hail from the Past juncture, you may be an actual member of the legendary Japanese secret society of assassins. But in Feng Shui, the term \u0026#8220;Ninja\u0026#8221; is also used generically to describe any operative who specializes in stealth and penetration missions. Although capable of holding your own during a fight, you prefer deception and surprise over the frontal assault. Ninjas maintain a mystique around themselves, often pretending to have secret mystical powers. Although the Ninja does have a passing acquaintance with esoteric chi abilities, the mystery surrounding you is mostly due to your own wit and presence. It is not fame that you crave so much as cultivating that mystique. You wish your deeds to be famous, but your identity a secret. You want to be feared. You want to be whispered about. Nothing amuses you more than to stand among people who have no clue just how quick and deadly you are. But lately, you have begun to feel a sense of emptiness. Maybe you have suffered a loss in love, or some other personal blow that has made you feel less invincible than usual. Perhaps you\u0026#8217;ve begun to question your amoral existence. When you discover the chi war, you are pulled in either by your melodramatic hook, or by the awakening of a desire to do something\u0026#8212;to leave a mark on the world, even if no one will ever know your name.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":8,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Ninja","Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":12,"Fix-It":11,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":15,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Architecture":15}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Scrappy_Kid_tvvhehmwj.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'df233719-e808-4146-aa94-c76efa1d9db4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Scrappy Kid',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Life is simple. You\u0026#8217;re a kid. You like to have fun. But there are these bad guys who want to wreck everybody\u0026#8217;s happiness. They think they\u0026#8217;re better than everyone else. They want to be the boss of you. So even though boring old grown-ups want to keep you safely tucked away somewhere stupid, you\u0026#8217;re gonna do something about it. After all, why should they get all the fun of shooting guns off and watching explosions and meeting cool monsters and all that stuff? Sure, you\u0026#8217;re not exactly a killing machine, like you plan to be when you grow up. But you\u0026#8217;re not bad for someone whose age isn\u0026#8217;t in the double digits yet. You\u0026#8217;re the best kung fu kid in your class, and you\u0026#8217;ve learned some tricks you weren\u0026#8217;t supposed to learn yet. And you\u0026#8217;re fast, you know how to duck, and bad guys underestimate you. Chi war\u0026#8212;hey, what could be cooler?\r\rYou don\u0026#8217;t have to play the Scrappy Kid as comic relief. (And shouldn\u0026#8217;t, if your GM and the rest of the group want to maintain a consistently dark and gritty tone in your Feng Shui series.) Maybe you\u0026#8217;re a grim little warrior, forced by tragedy to fght back in a grownup world. Just because you haven\u0026#8217;t hit puberty yet doesn\u0026#8217;t mean that you don\u0026#8217;t have a threatening squint worthy of Clint Eastwood.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":9,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":9,"Sorcery":0,"Creature":0,"Archetype":"Scrappy Kid","Toughness":4,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":9,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":10,"Fix-It":0,"Notice":0,"Police":0,"Driving":11,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":11,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Kid Culture":15}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Sorcerer_ByEi67FTL.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sorcerer',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You are a master of the occult arts, studied in the ancient techniques of channeling and transforming chi energy into a supernatural force, bent by your will. Some say this corrupts chi energy into what it was not meant to be. You call those people fools.\r\rAlthough there are many ways to do harm to an opponent, none has quite the awe-inspiring effect of an energy bolt cast from a magician\u0026#8217;s hand. You have some trouble manifesting your great powers in later junctures, such as our own and 1850, where the chi fow has been suppressed. But in other junctures, you access your unearthly abilities without impediment. However, in most places superstitious cretins assume that all sorcerers pursue sinister ends. True, most who follow the ways of the occult wind up doing great harm to the people. They have been corrupted by exposure to the Underworld, the home of demons and evil spirits. Or perhaps they have been seduced by their own lust for power. But that does not describe you! You have the will to resist, where weaker minds failed. Given the bad reputation of sorcerers, you have learned to keep your mystic abilities hidden as you fght for the right side of the chi war.\r\rWith the sorcerer\u0026#8217;s versatility comes some additional complexity. You will want to own a copy of the book to play it to the fullest.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":8,"Sorcery":14,"Creature":0,"Archetype":"Sorcerer","Toughness":6,"MainAttack":"Sorcery","FortuneType":"Magic","Max Fortune":8,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Thief_9jyirWew4.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '92783b56-c474-412d-95ca-9b23ee3f0b97',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Thief',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You are a master thief. Although you make your living taking things from their legal owners, you don\u0026#8217;t do so primarily for the money. Sure, you live in luxury from the proceeds of your past misdeeds. But it\u0026#8217;s the challenge that keeps your senses keen and your ambitions sharp. You operate through careful research, by assembling every available scrap of information about your target. When you go in, you have every angle planned out to the millisecond. You also plan for something to go wrong. That\u0026#8217;s when the adrenaline kicks in, when you have to think fast and get it right the frst time. When the alarms are screaming and the footfalls of heavily-armed guards are rushing your way, when the distance to your getaway vehicle seems impossibly vast in the moments you have left to you\u0026#8212;that\u0026#8217;s the moment you live for. The money is just gravy. Still, there\u0026#8217;s a thought nagging at the back of your skull that maybe all of this thrill-seeking is just a little bit meaningless\u0026#8212;maybe even adolescent. Lately you\u0026#8217;ve been thinking about leaving a positive mark on the world. Robbing from the rich and giving to the poor, or something like that. Is there a way to use your skills for the greater good?","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":9,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":16,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Thief","Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":12,"Fix-It":0,"Notice":0,"Police":0,"Driving":12,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":15,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Guns":12,"Info: Gems and Jewels":15,"Info: Art and Antiques":15}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Supernatural_Creature_bhUAJkBrv.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Supernatural Creature',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You are a being from the Underworld, a mystic realm haunted by demons and the spirits of the dead. You are yourself a being that humans would describe as a monster or evil spirit. But you are not evil, for even the spawn of the Underworld are capable of exercising free will and doing right instead of wrong. You realize, however, that almost none of your kindred bother to make this effort. They live to terrorize and to inflict pain. You did, too, until you were summoned and dominated by the cruel eunuch sorcerers of the Eaters of the Lotus. At first, you followed their orders\u0026#8212;you had no choice, shackled by mystic bonds. But eventually you were able, through intense mental effort, to break free of their influence. You saw around you people who lived in fear, people whose lives were seen as mere playthings by your Lotus masters. And although most demons would never even think such thoughts, you decided that you would atone for the wrongs you had done, and destroy those who had forced you to do them.\r\rSupernatural Creatures vary widely in appearance, but all are horrific. Some appear as decomposed human corpses, others as grotesque ogres. Others show no resemblance to the humanoid form. Although you may now fight for the forces of good, your alarming features prevent you from ever passing as a normal member of society.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":8,"Sorcery":0,"Creature":13,"Archetype":"Supernatural Creature","Toughness":7,"MainAttack":"Creature","FortuneType":"Magic","Max Fortune":8,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Featured_Foe_qetZaS6RG.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '3947d2d8-163a-4bdd-83e8-0de8f751e861',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Featured Foe',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"\u003cp\u003eA capable individual who assists the heroes in their adventures. This could be a trusted contact, a fellow warrior, a skilled informant, or any other non-player character who generally works alongside the party. Allies typically have competent combat or support abilities but aren''t as powerful as player characters. They might join fights, provide crucial information, offer safe havens, or assist with specialized skills the party lacks.\u003c/p\u003e","Background":"","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":12,"Type":"Featured Foe","Speed":6,"Damage":9,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":null,"Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Boss_4DZnkBtBV.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '7a367c9d-ad7f-4bc8-9050-30a58a9e4e99',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Boss',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"\u003cp\u003eA capable individual who assists the heroes in their adventures. This could be a trusted contact, a fellow warrior, a skilled informant, or any other non-player character who generally works alongside the party. Allies typically have competent combat or support abilities but aren''t as powerful as player characters. They might join fights, provide crucial information, offer safe havens, or assist with specialized skills the party lacks.\u003c/p\u003e","Background":"","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":12,"Type":"Boss","Speed":7,"Damage":10,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":null,"Toughness":8,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":16,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Ally_KjlHMU9ve.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'f0310e8e-871f-46c5-8497-f9e484824281',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ally',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"\u003cp\u003eA capable individual who assists the heroes in their adventures. This could be a trusted contact, a fellow warrior, a skilled informant, or any other non-player character who generally works alongside the party. Allies typically have competent combat or support abilities but aren''t as powerful as player characters. They might join fights, provide crucial information, offer safe havens, or assist with specialized skills the party lacks.\u003c/p\u003e","Background":"","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":12,"Type":"Ally","Speed":6,"Damage":9,"Genome":0,"Mutant":0,"Wounds":0,"Defense":12,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":null,"Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":12,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Info":12,"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Killer_7wAFQSERK.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Killer',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You used to work as a professional assassin. Maybe you serve an intelligence agency. More likely you whacked people for the triads. You prided yourself on cool, calculated efficiency and the ability to get the job done without getting involved. You know everything there is to know about the acquisition, handling and employment of firearms. You\u0026#8217;ve been perforated by bullets more times than you can count. What you call an occupational hazard. The intellectual puzzle of the perfect kill mattered to you then. The value of your life, or those of your victims, never factored into the equation. Until now. Possibly through your melodramatic hook, you are about to plunge into the the chi war. Now you have the power to change history with your trigger finger, instead of just wiping out unsuspecting target. And maybe, just maybe, that gives you a chance to redeem yourself...","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":15,"Type":"PC","Speed":9,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Killer","Toughness":6,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Martial Arts*":10}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Sifu_luGBqT3sr_.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Sifu',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Sometimes the greatest warrior fights by healing his comrades. With your mastery of pressure points, perhaps in tandem with Western medicine, you keep your fellow heroes up, when they would otherwise fall. Whether they\u0026#8217;re bruised, battered, scorched or riddled with bullets, you can supply the few miraculous jabs required to send them tottering back into the fight for another round of brutal punishment.\r\rYou serve as headmaster of a martial arts school, healer to the surrounding neighborhood, and beacon of wisdom for all who seek your counsel. You teach your students to embrace the honor and tranquility of Chinese philosophy. A man of peace, you were dragged only reluctantly into a battle with the injustices of your age, and from there into the fires of the chi war. You would sooner bring your adversaries to the light than kick them into the darkness. But because you are a humble as well as a learned person, you are not so arrogant as to think that you can heal everyone. When push comes to shove, sometimes the weak must be defended. On those sad days, you stop setting bones and start breaking them.\r\rWant to specialize in healing and denial attacks? Play the Sifu. If you\u0026#8217;d rather be the best at fu powers, though you falter in the stretch, play the Old Master.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Sifu","Toughness":7,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":14,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":15,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Calligraphy":15,"Info: Chinese Philosophy":14}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Transformed_Crab_NYbNoinI8.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'bd661084-c670-4910-b568-3a2962a621e5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Transformed Crab',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"In the Ancient juncture, animal spirits from the supernatural realm between being and non- being sometimes yearn for the vividness of mortal existence, and through innate magic assume human form. They face not only the dangers brought by strange and powerful human emotions, but the efforts of exorcist monks, who seek to strip them of their new identities, sending them howling back to the spirit world.\r\rSometime between then and the Past, transformed animals banded together to prevent them from doing this. By slowly leaching magic from the world, they made it much harder for exorcists and sorcerers to banish, control, or revert them to their old status as intelligent snakes, foxes, tortoises, spiders, and so on. Once established, this alliance sought to protect itself by amassing political power. By the 19th century, these so-called Ascended secretly rule the world, as they continue to do in Modern times. \r\rDepending on when you were born, you might have literally changed from an animal into a human, or have such an individual way back in your family lineage. You may or may not know any of the secretive transformed animals of the Ascended, who fight the geomantic battle to keep magic difficult in the Past and Modern eras. Somehow destiny throws you into the chi war not on their side, but with the anarchic, freedom-loving Dragons.\r\rYou were, or descend from, a truculent crab spirit, ferce and determined to protect itself and its loved ones from the many harms of a hostile world. Some threat has lured you reluctantly from the safety of your carefully constructed life. Whoever steps on you will live to regret it.","Hair Color":"","Style of Dress":"","Melodramatic Hook":""}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":8,"Sorcery":0,"Creature":0,"Archetype":"Transformed Crab","Toughness":8,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":8,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":11,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Intimidate":13,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Guns":10}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Karate_Cop_UcSmAlAWMJ.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Karate Cop',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You are a loyal, team-playing officer of the law who happens to be about as adept in the martial arts as you are with your service revolver. You overcome the bad guys not by being bigger or tougher but by sheer pluck and perseverance. When you punch a huge slab of a goon in the jaw, it hurts your hand. When you leap from a bridge to a passing hovercraft, you feel the impact roll up through your body. When fireworks set your jacket aflame mid-fight, you struggle awkwardly to put it out. You\u0026#8217;re not the most graceful combatant of the chi wars, or able to manifest the bizarre fu powers of the ancient masters. But no matter how many times they knock you down, you get back up, shake off the pain, and keep running after the wrongdoers.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Karate Cop","Toughness":7,"MainAttack":"Martial Arts","FortuneType":"Fortune","Max Fortune":7,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":15,"Driving":11,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Guns":13}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Old_Master_Y2SF8Kv9v.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Old Master',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You are an elderly expert who long ago conquered the most difficult principles of martial arts and chi powers. You spent many long years tutoring others in the secrets of your art, and are used to being treated with utmost respect. You can therefore be a bit of a hothead when challenged by others who do not know enough to bow before your superior experience. You are a harsh disciplinarian; no matter what juncture you hail from, you grumpily pine for the good old days when proper respect was paid to elders and the heavens were in harmony with the Earth. Although you no longer possess the physical strength and endurance you had as a young student, your skill and Chi powers still make you a formidable opponent. You want to retire from active participation in the world of martial arts, leaving the field to the young men and women you have trained to follow in your footsteps. Now you want to rest, and to study the arts and ancient poems. But the tide of evil in the world seems to be growing again. You must show a new generation of heroes to become masters themselves, as your masters taught you. Used to deference and with bones growing more tired by the day, you can be surprisingly cranky, even comically crude, when crossed. Some life lessons are best imparted with a clout upside the head.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":10,"Sorcery":0,"Creature":0,"Archetype":"Old Master","Toughness":5,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":10,"Martial Arts":16,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":11,"Constituion":0,"Intimidation":0,"Info: Calligraphy":15,"Info: Chinese Philosophy":15}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Exorcist_Monk_4NiZhLDNH.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Exorcist Monk',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Few know this, but the chi war began when impudent beings from the spirit world entered the world of man and began to interfere with it. This began the great imbalance that granted geomantic power to rascals and men of violence, and opened up ruptures between time periods. For the world to return to peace, enabling people to once again pursue enlightenment through detachment, the spirits must be sent back where they belong. You, a wise and therefore powerful monk, have descended from the serenity of your mountain monastery to perform the necessary exorcisms. Though you\u0026#8217;ll not turn a blind eye to other evils, none of them can be truly vanquished until your central task is done.\r\rBefore choosing this archetype, check with your GM to make sure you\u0026#8217;ll be encountering enough magic opponents to make it fun.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":8,"Sorcery":0,"Creature":0,"Archetype":"Exorcist Monk","Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":8,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Gambler_x8gwcAi33V.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'f7d9c375-eee7-47ec-8975-90aefe08000a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Gambler',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"As a devil-may-care hang-glider on the winds of fate, you\u0026#8217;ve turned natural luck and a fair for getting yourself out of scrapes and into a profitable career. You\u0026#8217;ve learned to handle yourself in a fght\u0026#8212;not all losers are good sports, after all. But mostly you rely on your drop-dead smile and your airtight instincts to keep yourself out of trouble. With these two weapons at your disposal, you\u0026#8217;ve carved out a life of luxury for yourself\u0026#8212;no pleasure is too fashy or shallow for your tastes. You came from humble beginnings and made your fortune using only your brains and your need for victory. The latest clothes, the shiniest gadgets: these are things you\u0026#8217;ve dreamed of since childhood. But the real prize is the sheer joy of beating the odds, of triumphing over your opponents when logic decrees that you should be down for the count. Now a melodramatic hook pulls you into the chi war, a situation where all of the odds you\u0026#8217;ve memorized are turned upside down. Nonetheless, you face this new adventure with a grin and a heaping helping of aplomb. You know it won\u0026#8217;t take you long to fgure the angles.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":8,"Sorcery":0,"Creature":0,"Archetype":"Gambler","Toughness":6,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":8,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":15,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":13,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Criminal Underworld":13,"Backup Attack: Martial Arts":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Driver_WBj1QY2PK.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Driver',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Chill-out electrobeat pulses from your speakers. Sodium-lit empty highway snakes out before you. With gentle control you accelerate. You are your car. You are at peace. Existential zen zen zen.\r\rEveryone covets your skills. Fast drivers meet demands in dark places. A vehicle like yours doesn\u0026#8217;t pay for itself. So you cross a line or two.\r\rStay cool, cool, cool, you tell yourself. Forget everything else. Just be the road. Who are you fooling? Jacketed inside that cool, bottled within all that control, burns six-twenty horsepower of rage, rage, rage.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":8,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Driver","Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Fortune","Max Fortune":7,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":12,"Notice":0,"Police":0,"Driving":15,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Ghost_X64N93uVK.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '317a298c-a051-46f2-9eb4-1833503fbcf6',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ghost',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Ghosts aplenty haunt the magic-rich ancient juncture. You are one of these\u0026#8212;a spirit unwilling or unable to leave the trappings of mortal life behind to join the eternal cycle of reincarnation. The Netherworld is also home to many ghosts, former chi warriors whose life forces were too strong to depart the Inner Kingdom when their physical bodies died. Other ghosts prey on mortals, motivated either by jealousy of the living or by the same malign intentions they harbored in life. But you are tied to the Earth for some other reason. Your soul cannot rest, for in life you swore a solemn oath to complete some great undertaking. This crucial unfnished business probably comprises your melodramatic hook. You may have sworn to protect someone, to wreak vengeance on an enemy, or to recover some lost treasure or artifact. Ghosts have a bad habit of falling in love with mortals, and can often be stunningly beautiful and alluring. Although you know such loves are forbidden, you may already fnd yourself in a romantic entanglement that crosses the sacred barrier between the living and the dead. If you are not in such a doomed relationship, you are suffciently prone to such temptations that you might end up in one before the series is out.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":12,"Fortune":8,"Sorcery":13,"Creature":0,"Archetype":"Ghost","Toughness":6,"MainAttack":"Sorcery","FortuneType":"Magic","Max Fortune":8,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":13,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Musicianship":13}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Private_Investigator_TpRwpVpiB.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'd9ad1bc8-db91-43ba-8371-fe883ab72aa3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Private Investigator',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"As an experienced investigator you have accumulated contacts throughout society: from well-heeled clients who can afford to hire you, to the enforcers of the law you must occasionally skirt, to the seediest elements of the underworld. You most often work for lawyers, digging up information for use in court cases. When one corporation sues another, you find yourself poring over corporate ledgers and sifting for obscure references in old business publications. You\u0026#8217;ve worked for insurance companies, keeping plaintiffs under surveillance to see if they\u0026#8217;re as injured as they claim to be. And then of course there are divorce cases. Although you may have gotten into your line of work because you fell in love with the film noir world of Philip Marlowe and Sam Spade, you\u0026#8217;ve spent more time hunched over a laptop performing background checks than you have slugging it out with gangsters and crooked cops. Maybe that\u0026#8217;s why, when you sniff out the first clues that point you to the existence of the chi war, you\u0026#8217;re ready to chuck the real-life world of the private detective in favor of the fantastic adventure you\u0026#8217;ve always dreamed of.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Private Investigator","Toughness":7,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":15,"Info: Law":11,"Intrusion":11,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Business":14,"Backup Attack: Martial Arts":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Ex-Special_Forces_V0KO0ma6Q.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Ex-Special Forces',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Afghanistan. Iraq. Places you still aren\u0026#8217;t allowed to name. A former member of an elite force trained in counter-terrorism, hostage rescue, and sabotage missions, you had a hard-bitten military mindset drilled into you along with your extensive list of deadly skills. It is possible that you were dishonorably discharged from your beloved unit, fairly or otherwise; this might be your melodramatic hook. People keep expecting you to relax, to kick back, to get along, just like everybody else. But you can\u0026#8217;t. Your nerves are still on edge. Whenever you get into a fender bender, or a confrontation on the street, it takes all of your determination not to leap on the guy harassing you and beat him to a pulp. You long for a new cause to believe in, one you can feel as much fervor for as your old corps. Most of all, you want the pure rush you get from combat. There\u0026#8217;s nothing you\u0026#8217;d like more than to feel the taste of blood and fear in your mouth on another battlefeld. If that battlefeld involves a fight for justice and freedom against tyrants from across the timestream, so much the better.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":14,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Ex-Special Forces","Toughness":7,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":7,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":12,"Strength":0,"Detective":0,"Intrusion":11,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Anti-Terrorism":15,"Backup Attack: Martial Arts":13}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Magic_Cop_Vj0e_-HWE1.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Magic Cop',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Even in junctures where magic is rare and difficult to perform, supernatural manifestations still ooze from the world\u0026#8217;s dark corners, with sometimes lethal results. Many large police jurisdictions secretly maintain small units of officers trained in the mystic arts. These cops are able to take on the occasional renegade sorcerer or shaman who might pop up, and can dispatch demons and ghosts without freaking out. You are one of these cops. You\u0026#8217;re probably a loner; the system is set up so you have little contact with regular law enforcement officials. Other officers think you\u0026#8217;re nuts, if they know who you are at all. You have built up tough mental defenses against the creatures of the night. To normal folks, you come off as grim or aloof. You might think of yourself as a holy warrior, implacably gunning down anything that smacks of the occult. Or maybe you wish you could build a bridge between the world of the supernatural and the world of everyday humanity. Magic cops are often drawn into the chi war as they hunt down agents of the Lotus or escapees from the Netherworld, discovering that there is much hidden beneath reality\u0026#8217;s mundane veneer that even they know nothing about.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":14,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":8,"Sorcery":0,"Creature":0,"Archetype":"Magic Cop","Toughness":7,"MainAttack":"Guns","FortuneType":"Magic","Max Fortune":8,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":12,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Info: Occult":13,"Intimidation":0,"Back-Up Attack: Sorcery":13}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Gene_Freak_GMw5LRhKP.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Gene Freak',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Bizarre energies released by the cataclysmic destruction of a futuristic hyper-Orwellian regime swirled through your world, altering the DNA of hapless survivors. Most died, but a few survived, twisted, traumatized, but able to manifest previously unknown bodily feats.\r\rSome energies escaped through poisoned feng shui sites into the present day. Often believing themselves to have been changed by brushes with ordinary radiation or other experiments gone awry, a handful of moderns also acquired credibility-defying super powers.\r\rMost gene freaks want to be left alone. Maybe you do, too, but a melodramatic hook prevents it. Or maybe you\u0026#8217;ve decided to take an active, heroic part in the chi war in search of a cure, or to show that some cursed with unwanted might can wield it with responsibility and discipline.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":13,"Wounds":0,"Defense":13,"Fortune":9,"Sorcery":0,"Creature":0,"Archetype":"Gene Freak","Toughness":6,"MainAttack":"Mutant","FortuneType":"Genome","Max Fortune":9,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Everyday_Hero_ZP6oWDxOH.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '8d1afe00-b16f-4698-95f3-64fc2e997f9e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Everyday Hero',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You might be nobody special, but that\u0026#8217;s the source of all your awesome. Unlike some archetypes you could name, you work for a living, probably in a good, honest, vanishing blue collar job. Maybe you\u0026#8217;re a factory worker, a truck driver, a plumber, or a sailor. You may be on vacation when the action begins, or find yourself in a crossfre as the result of a job-related errand. Aside from taking care of your melodramatic hook, all you really want to do is sit down with a can of beer and watch some sports at the local bar. But somehow trouble always comes looking for you. That\u0026#8217;s because of your basic, essential decency and/or stupidity. And also your peculiar luck. On one hand, your luck gets you through situations that even you don\u0026#8217;t believe you could survive. But on the other hand, your luck tends to get you into weird and frightening situations to begin with because the good guys need your help. You may not be the smartest, or the strongest, or the most skilled person in the world. But you\u0026#8217;re a good guy, and \u0026#8220;Good guys always fnish\u0026#8212;ugh! Hey, wha\u0026#8217;d you shoot me for? Oh, man, now I\u0026#8217;m bleeding... howzabout a knuckle sandwich?\u0026#8221; A good choice if you like to play mechanically simple characters.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":9,"Sorcery":0,"Creature":0,"Archetype":"Everyday Hero","Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Fortune","Max Fortune":9,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":12,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Info: Beer":15,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Sports Fan":15,"Info: Classic Cars":15,"Info: Classic Rock":15,"Backup Attack: Guns":11}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Maverick_Cop_oVSKaQMHj.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Maverick Cop',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"The Maverick Cop is a plainclothes detective assigned to a major crime unit of a big city. You may work undercover, you may be in an anti-mob unit, or you may be a homicide detective. Good-looking but slovenly, you may cultivate a drinking problem and definitely have a personal life in a state of serious disorder. Despite the fact that you are one yourself, you\u0026#8217;ve always had a problem with authority figures. You see yourself as a loner, but this may date back only as far as your last partner getting killed, or the origin point of some other your melodramatic hook. You are always on the verge of being fired and are often on suspension. You keep your job only because your gruff superior officer has a secret soft spot for you, and because you get results. Although you always get the job done in the end, things always seem to conspire to make you look bad. People connected to your investigations have a habit of getting killed. Witnesses get snuffed. Bystanders fall like tenpins whenever you take part in a firefght. Most of all, you never seem to be able to just apprehend a crook. It\u0026#8217;s not like you deliberately set out to empty the contents of your high-caliber revolver into each and every scumbag you\u0026#8217;re supposed to arrest. You warn them even, tell them they shouldn\u0026#8217;t be feeling lucky, shouldn\u0026#8217;t ever get you riled. Punks never learn.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":7,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Maverick Cop","Toughness":8,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":15,"Driving":13,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Dive Bars":15,"Backup Attack: Martial Arts*":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Two-Fisted_Archaeologist___CUtxSbL.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '2c2efc13-84ce-45d5-9549-b5b058b2ebe0',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Two-Fisted Archaeologist',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"The past is dangerous. Your years as a field historian have proved that time and time again. Magic isn\u0026#8217;t mere myth\u0026#8212;it used to be stronger, and pockets of its power reside in the iconic treasures your museum trustees back home most want you to find and bring back for their display cases. Through bitter experience you\u0026#8217;ve learned that some of these are best stored in secure facilities, where the chaos they\u0026#8217;d unleash cannot threaten humanity.\r\rBy seeking these items you\u0026#8217;ve nosed your way into a covert battle waged with history as its prize, and knowledge of that history a key weapon. Your rivals have ranged from unscrupulous profiteers to hallucinogen-snorting cultists to reactionary terrorist groups. The archaeological sites you\u0026#8217;ve dedicated your professional life to resonate with mystical energies, making them strategic prizes in that fight. To protect both innocent lives and the precious heritage of these sites, you\u0026#8217;re about to join the chi war.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":8,"Sorcery":0,"Creature":0,"Archetype":"Two-Fisted Archaeologist","Toughness":7,"MainAttack":"Martial Arts","FortuneType":"Fortune","Max Fortune":8,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":11,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: History":15,"Backup Attack: Guns":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Uber-Boss_U8sbOJpEc.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'aaf89162-4329-4924-9141-dd8ba02c13a8',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Uber-Boss',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"\u003cp\u003eThe ultimate villain who represents an apocalyptic threat to the world. Uber-Bosses are campaign-defining antagonists with overwhelming power, vast resources, and world-shaking ambitions. These are your demon kings, ancient sorcerers, time-traveling warlords, and megalomaniac masterminds who orchestrate events from behind the scenes. They command armies, possess legendary artifacts or supernatural powers, and typically require an entire campaign''s worth of preparation to confront. Defeating an Uber-Boss often marks the climactic end of a campaign or major story arc.\u003c/p\u003e","Background":"","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":12,"Type":"Uber-Boss","Speed":9,"Damage":14,"Genome":0,"Mutant":0,"Wounds":0,"Defense":17,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":null,"Toughness":9,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":19,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Mook_o6NQRGwDb.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '67f709a8-521f-48b5-a3d6-cee40868236a',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Mook',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"\u003cp\u003eNameless thugs and minions who attack in groups. These are the faceless enforcers, gang members, cultists, guards, and henchmen who serve as cannon fodder in fight scenes. Mooks go down with a single hit regardless of damage dealt, making them perfect for those cinematic battles where heroes plow through waves of enemies. They typically appear in groups of 5-10 and their main threat comes from overwhelming numbers rather than individual skill.\u003c/p\u003e","Background":"\u003cp\u003eA capable individual who assists the heroes in their adventures. This could be a trusted contact, a fellow warrior, a skilled informant, or any other non-player character who generally works alongside the party. Allies typically have competent combat or support abilities but aren''t as powerful as player characters. They might join fights, provide crucial information, offer safe havens, or assist with specialized skills the party lacks.\u003c/p\u003e","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":12,"Type":"Mook","Speed":5,"Damage":8,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":null,"Toughness":6,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":8,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Big_Bruiser_1Xqe8U7fVY.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Big Bruiser',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"With your size and strength, you cast an intimidating shadow across the scene of any fight. You don\u0026#8217;t hit as often as other combatants, but when you do, look out! Your massive frame allows you to withstand blows that would fatten a smaller fighter. Most people assume you\u0026#8217;re stupid, and maybe you are\u0026#8212;but maybe not, letting you play their misperceptions to your advantage. You may have worked as a manual laborer, or as a guard of some kind. You might be a quiet, gentle giant or a bullying loudmouth. You are definitely a mountain of determination and endurance.\r\rMake best use of your mammoth damage by going toe-to-toe with the group\u0026#8217;s major foes. To specialize in taking out mooks, play a Killer or Masked Avenger.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":11,"Type":"PC","Speed":5,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":12,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Big Bruiser","Toughness":12,"MainAttack":"Martial Arts","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":12,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":"Guns"}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":14}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Bandit_GsvWOhYFk.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Bandit',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Nobody starts out wanting to be a bandit. You began life as a farmer, craftsman or merchant. Then disaster struck. A food destroyed your farm. Imperial taxes drove you into poverty. Perhaps you were the victim of other bandits. In any case, you turned your back on society. You began to live off what you could steal. With guile and determination, you turned survival into not only a way of life, but a source of inspiration for others. What life dished out to you, you took, and converted into power. Other bandits now flock to you. Imperial soldiers hunt you. Merchants shudder whenever someone speaks your name. And yet, you find yourself returning to the very society that you once abandoned. Something draws you there\u0026#8212;something you wish to fight for\u0026#8212;something you must defend. You have taken the first few steps on a new road. It leads either to redemption, or to death.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":15,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Bandit","Toughness":8,"MainAttack":"Martial Arts","FortuneType":"Chi","Max Fortune":7,"Martial Arts":13,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":12,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":12,"Constituion":0,"Intimidation":12,"Info: Peasant Life":15}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Archer_ZRW-zqtCC.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Archer',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"You exert supreme mastery over mankind\u0026#8217;s perfect missile weapon, the bow and arrow. With perfect serenity you pull the drawstring. With a sense of time\u0026#8217;s crystalline nature, you divide the moment of aiming into a spiderweb of interlocking infinities. At the moment of precision, you loose the string. Your mind\u0026#8217;s eye fies through the air, following the arrowhead as it closes the distance between you and your target. With the silence of the serpent, it strikes. Already you have drawn another arrow, ready to repeat. Guns may be louder, faster, more destructive. But no one deals death more beautifully than you.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":14,"Type":"PC","Speed":8,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":14,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Archer","Toughness":6,"MainAttack":"Guns","FortuneType":"Chi","Max Fortune":7,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":9,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Info (any)":11,"Leadership":0,"Constituion":0,"Intimidation":0,"Info: Chinese Philosophy":13,"Backup Attack: Martial Arts":12}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Cyborg_NxxIsyjaP.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  'ac248717-2f82-44b5-ac39-83b582777a96',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Cyborg',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"An inhabitant of the scorched future juncture, you suffered a fate that should have killed you. Recovered by radiation-addled members of the Jammer cult, you begged for a merciful demise. Instead they tried to save you, using their bizarre scrounged technology. You returned to consciousness both better and worse than before, an amalgam of mangled humanity and barely operational robotic prosthetics. Impelled onward by a cranial chip that won\u0026#8217;t let you kill yourself, you plunge into the the chi war in search of a cure for your freakish condition\u0026#8212;or maybe just the oblivion destiny continues to withhold from you.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":0,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Cyborg","Toughness":9,"MainAttack":"Scroungetech","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":0,"Scroungetech":13,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":13,"Notice":0,"Police":0,"Driving":0,"Gambling":0,"Medicine":0,"Sabotage":13,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Guns":13}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Drifter_VDrjLiU4P.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Drifter',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Whatever your story is, you ain\u0026#8217;t tellin\u0026#8217;. Constantly on the move, you want nothing more than to be left alone\u0026#8212;and maybe the simple pleasures of life, like a cold drink on a hot day. Destiny, that well known son of a bitch, has other plans. You have a knack for wandering into other peoples\u0026#8217; trouble, and a conscience that won\u0026#8217;t let you stay out of it. Whenever thugs are threatening a helpless young widow, you\u0026#8217;ll be there. Whenever criminals become the law, you\u0026#8217;ll be there. There with a great big freaking gun. And if you have to plant a bunch of them in the ground, well, you always warn them not to mess with you.\r\rA great choice if you know you\u0026#8217;ll be attending game sessions irregularly.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":6,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Drifter","Toughness":8,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":7,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":11,"Notice":0,"Police":0,"Driving":0,"Gambling":11,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Martial Arts*":11}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Full-Metal_Nutball_oPZHL34c-o.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '23bde1d7-2561-4418-bd1b-47920351338d',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Full-Metal Nutball',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"They call you a gun nut. Accent on the gun. Well, also, come to think of it, accent on the nut. Okay, okay, sure, they apply equally. Except that you don\u0026#8217;t just love guns. You delight in ordnance of all kinds, the more explosive the better. Your weird little hideout bristles with rare, illegal and just plain impractical weaponry. How you acquired it all with no visible means of a support may be revealed in the course of play, or remain a mystery hardly worth addressing. You don\u0026#8217;t shoot your firearms as well as you lovingly care for them, so when you finally get a chance to pull the trigger for real, the results skew toward the slapstick as well as the lethal. When you meet real deal shooting and killing types, you try to contain your drooling enthusiasm, but when things get hot the whooping and hollering starts. Mostly you come off as a lovable oddball. In addition to your pistolophilia, you likely spout various paranoid beliefs. When you stumble into the secret war, you may be as surprised as any when you discover how right you\u0026#8217;ve been!","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":8,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":7,"Sorcery":0,"Creature":0,"Archetype":"Full-Metal Nutball","Toughness":6,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":7,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":15,"Notice":0,"Police":0,"Driving":10,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Image URL: https://ik.imagekit.io/nvqgwnjgv/chi-war-development/Highway_Ronin_WRev4WOp_.png
INSERT INTO characters (
  id, campaign_id, name, description,
  action_values, skills, active,
  faction_id, created_at, updated_at
) VALUES (
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'Highway Ronin',
  '{"Age":"","Height":"","Weight":"","Eye Color":"","Nicknames":"","Appearance":"","Background":"Until you discovered the chi war, you drove the desolate highways of the shattered future, not to get somewhere, but to escape from everywhere else. You fought for gasoline, for your freedom from captivity, and sometimes to avoid ending up on a cannibal\u0026#8217;s flame grill. When confronted with the helpless, the desperate, you told them they didn\u0026#8217;t need another hero. But in the end, you stepped up, and drove your battered but trusty vehicle against the strong, to protect the weak. Now you\u0026#8217;ve learned of the chi war, and the real reason your world imploded, you figure your survival skills might be turned to an ultimate purpose\u0026#8212;to rewrite the history of the future, so the huddled masses need never fear again.","Hair Color":"","Style of Dress":"","Melodramatic Hook":null}',
  '{"Guns":13,"Type":"PC","Speed":8,"Damage":0,"Genome":0,"Mutant":0,"Wounds":0,"Defense":13,"Fortune":6,"Sorcery":0,"Creature":0,"Archetype":"Highway Ronin","Toughness":7,"MainAttack":"Guns","FortuneType":"Fortune","Max Fortune":6,"Martial Arts":0,"Scroungetech":0,"Marks of Death":0,"SecondaryAttack":null}',
  '{"Will":0,"Deceit":0,"Fix-It":0,"Notice":0,"Police":0,"Driving":14,"Gambling":0,"Medicine":0,"Sabotage":0,"Strength":0,"Detective":0,"Intrusion":0,"Seduction":0,"Leadership":0,"Constituion":0,"Intimidation":0,"Backup Attack: Martial Arts*":13}',
  true,
  NULL,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  '0ae9913e-02f6-4fae-9453-150d3167091e',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  '9afef0d9-233c-4696-b237-aed0515e0500',
  'Future Juncture',
  '<p>The technologically advanced future timeline before the C-Bomb''s detonation was a totalitarian state where enhanced apes had overthrown their human creators and established simian supremacy across the globe. Under the New Simian Army''s rule, cyber-enhanced gorillas, chimpanzees, and other primates occupy all positions of authority while humans are relegated to second-class status or outright slavery, their former roles as the dominant species reversed through superior technology and organized rebellion. Furious George and his militant followers have built a society that celebrates simian intelligence and physical prowess, using advanced cybernetics and recovered pre-war technology to maintain control over sprawling megacities where propaganda broadcasts remind all citizens that evolution has chosen apes as Earth''s rightful inheritors. This oppressive future serves as both the New Simian Army''s greatest triumph and their ultimate tragedy - they achieved everything they fought for, only to have it all destroyed when the Jammers'' C-Bomb wiped out their perfect world and scattered the survivors across the timelines.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  '2e6a9b7a-2ca6-4a6f-968a-9654ac58d1e7',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  '8a2a13dc-447f-4e71-98fd-732c8d65be78',
  'Ancient Juncture',
  '<p>The golden age of Tang Dynasty China under the iron rule of Empress Wu Zetian represents the height of Chinese imperial power and magical abundance, but the glittering court ceremonies and administrative efficiency mask a sinister reality - pale, long-fingernailed eunuch sorcerers manipulate every policy decision from the shadows of the Forbidden City. While Wu Zetian sits upon the Dragon Throne as China''s only female emperor, commanding vast armies and overseeing cultural flowering, the corrupt Eaters of the Lotus pull the true strings of power through their positions as palace intermediaries, using dark magic to summon demons, bind spirits, and twist the empire''s abundant chi flow to serve their malevolent purposes. In this juncture where magic flows freely and feng shui sites pulse with visible energy, the eunuchs have created the perfect system - they remain hidden behind screens and curtains while their supernatural servants enforce their will, turning the most prosperous period in Chinese history into a feeding ground for their occult ambitions as they corrupt the Mandate of Heaven itself.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  '4d64ba1d-879e-4de3-ba61-f85eb25cc2b4',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'c52de513-622e-4bda-a88e-cec2a5c13ddb',
  'Past Juncture',
  '<p>The twilight years of Imperial China represent a period of profound crisis where traditional Confucian civilization faces annihilation by foreign colonial powers, but the ancient wisdom of Buddhist monks and Shaolin masters offers the last hope for cultural survival through the secret network known as the Guiding Hand. While British gunships enforce opium trade in Chinese harbors and Western influence corrupts the imperial court, Perfect Master Quan Lo and his followers operate from hidden mountain monasteries and underground Golden Candle Societies, using their mastery of feng shui, martial arts, and traditional philosophy to organize resistance against foreign domination and moral decay. In this juncture where chi flows more freely than in the modern world but less abundantly than in ancient times, the Guiding Hand represents the bridge between spiritual enlightenment and political action - they train peasants in kung fu, teach merchants to resist corruption, and guide government officials toward righteous governance, all while protecting the sacred feng shui sites that maintain China''s spiritual integrity against the encroaching darkness of Western materialism and the Lotus eunuchs'' supernatural corruption.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  '49729394-c8fd-438e-ba06-a801092c0594',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'f9c89687-9813-4c50-98fb-ceecfcc5e335',
  'Modern Juncture',
  '<p>The Contemporary world appears to be a normal late 20th/early 21st century Earth, but beneath the surface lies a carefully managed reality controlled by the Ascended conspiracy - descendants of transformed animals who have spent centuries positioning themselves in positions of power across every major corporation, government agency, and media outlet. This juncture represents the pinnacle of their control, where magic has been suppressed to near-extinction through their dominance of feng shui sites (disguised as corporate headquarters and cultural landmarks), keeping them safe from reverting to their animal forms while the general population lives in blissful ignorance of the supernatural world, dismissing magic as superstition while unknowingly serving their inhuman rulers who pull the strings from boardrooms and government offices around the globe.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  '2c6289f5-e827-4ebb-a545-a83966e3c6ea',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'd12ebf38-6bf4-485d-ab01-36e71e99306a',
  'Future Wasteland',
  '<p>The post-apocalyptic wasteland that remains after the C-Bomb''s detonation is a harsh realm where survival depends on gasoline, firepower, and allegiance to the only functioning authority left standing - General Grundle''s mechanized empire. From his massive throne built of salvaged technology, the grotesquely obese cyborg warlord controls every drop of fuel, every functioning weapon, and every scrap of useful machinery through a network of road warrior gangs, scavenger crews, and armored convoys that battle across the endless desert highways for resources and territory. In this burned-out future where civilization has collapsed into tribal automotive warfare, Grundle''s word is absolute law - those who serve him receive protection and fuel rations, while those who defy him face his armies of weaponized vehicles and cybernetic enforcers in a world where the only remaining currency is violence and the only escape is death.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  '044041d8-94b9-4551-9c01-5adff074c5a5',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  NULL,
  'Netherworld',
  '<p>The Netherworld is a supernatural realm of impossible architecture and ever-shifting reality where the exiled Four Monarchs hold dominion over vast territories that reflect their elemental natures - Li Ting''s volcanic empires of molten glass and eternal flame, Huan Ken''s gothic cathedral-fortresses wreathed in perpetual storms, Pi Tui''s crystalline palaces where time moves like frozen honey, and Ming Yi''s shadow-cities that exist in the spaces between light and darkness. This dimension serves as both prison and kingdom for the siblings who once ruled the entire world, its malleable laws of physics allowing them to reshape reality according to their will while trapping them away from the mortal realm they desperately wish to reclaim. Here, demons and spirits serve as courtiers, the landscape responds to the Monarchs'' emotions, and the boundaries between different domains shift like the tide - yet for all their godlike power within this realm, the Four Monarchs remain fundamentally exiles, their magnificent courts and elemental armies serving as constant reminders of the earthly empire they lost and the cosmic revenge they still plot against the world that banished them.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO junctures (
  id, campaign_id, faction_id, name, description,
  active, created_at, updated_at
) VALUES (
  'ffc77a44-da5c-4dc8-83a4-469cf1699ba2',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  'c44f7eaf-425b-497f-b278-92a3bc612e55',
  'Cyberpunk Future',
  '<p>The gleaming neon-soaked megacities of the near future are dominated by the Manlysaka Corporation, a techno-industrial empire run by the cyborg executive Ma Yujun who has systematically elevated cybernetic enhancement from luxury to necessity while positioning "pure" humans as an obsolete underclass. Under Manlysaka''s corporate hegemony, employment, housing, medical care, and even basic civil rights are tied to one''s degree of cybernetic modification - the more machine parts you possess, the higher your social status and access to resources, while unenhanced humans are relegated to sprawling slums beneath the chrome towers where cyborg elites conduct business at the speed of thought through neural networks. Ma Yujun''s vision of transhumanist evolution has created a society where the boundary between flesh and machine has been deliberately blurred through corporate policy, addictive technology, and economic coercion, turning the entire population into either willing converts to his cybernetic faith or desperate refugees hiding from mandatory "upgrades" in a world where being fully human has become both a political statement and a death sentence.</p>',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  '369822c5-aa28-4356-96be-f7a3a6a3d802',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  '28d79421-72c7-4db7-a8c0-5638eb7d0078',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  'd508b89a-0caf-43be-b4a6-44c83af2bf3c',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '23bde1d7-2561-4418-bd1b-47920351338d',
  'a869dfb7-3476-4683-9a37-180905729475',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '23bde1d7-2561-4418-bd1b-47920351338d',
  '267dbdc9-6147-4d75-9fe0-9491e1221853',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '23bde1d7-2561-4418-bd1b-47920351338d',
  '103cae55-5a4c-4739-8d2b-9570192a31c4',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '23bde1d7-2561-4418-bd1b-47920351338d',
  'c0e6899d-7aed-406e-a9e0-ca24a7b48afb',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '23bde1d7-2561-4418-bd1b-47920351338d',
  'e04978bf-fcbc-4a2a-9929-bbffead92518',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  'ac3fe2a9-3b8d-44c3-8236-2532f6680193',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  'e22db50f-ec48-40e3-9375-4cfdd19054e8',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  '0d04db78-bffd-4284-a372-15974addef44',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  '2592f5e5-bd23-4cca-8766-45907c67a7ea',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  'aaec7ba9-f4a3-44b7-9096-8fe927a871ab',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  '5eb84b6f-89b7-446b-890f-0a756777831b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '3188fe9b-049f-4580-b87b-d543c819cdec',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '0d3df1d1-b661-4ca6-8a24-ff6a2db55314',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  'f4a25039-594b-4b2d-9855-57cd299d17a0',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  '3c5d0fa1-1afa-4f0b-ace6-5e51fcb8f263',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  '1859c6fa-27a8-44bc-9460-11435fef6283',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  'ea04152e-5c0a-40f7-98a3-42f50c3731bd',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  '0d3df1d1-b661-4ca6-8a24-ff6a2db55314',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f7d9c375-eee7-47ec-8975-90aefe08000a',
  '1fb78e49-3f1e-4dc1-a208-c40ee9ec85ed',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f7d9c375-eee7-47ec-8975-90aefe08000a',
  '2dc90091-9cdd-47f5-b3ee-af0e3d39c80d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'f7d9c375-eee7-47ec-8975-90aefe08000a',
  '54eabed0-4b0f-46c7-bf37-4ce69f0346a2',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  '623fd0e1-d6e1-412f-95bf-acefbb699540',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  '910e0d39-2532-4f42-9cc1-2d5979d4143e',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  'cdd7fcf7-be06-437b-bae9-e8eba710ecd4',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  '63115496-cb41-49c8-8f19-4df330907f5b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  'c6242be8-1b59-4def-bf57-47d5ede995ff',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  '75ef111f-aa53-4e4b-92bc-79dd0ee293aa',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  'c102ecbe-b039-4a34-aea1-1d574f3ed858',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'df233719-e808-4146-aa94-c76efa1d9db4',
  '1f0345c5-b52e-4303-a458-17cc98f9c10f',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'df233719-e808-4146-aa94-c76efa1d9db4',
  '524df926-f0f6-4ed2-9b1b-897adc958cc4',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  '850719bf-21f7-4191-86fe-3df8a4a00f71',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'df233719-e808-4146-aa94-c76efa1d9db4',
  '67c8aae0-bf97-4ecf-9870-8c8ee26089ef',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  '79948b66-7e11-449f-b605-cd02487559d8',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'df233719-e808-4146-aa94-c76efa1d9db4',
  '59c0007d-e71d-43ea-a6f2-d26c6ceda8fb',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  '1630c04e-860f-49d2-9c7f-cf821ad4a72b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  'd7e3578e-5e5e-4fae-b2f7-54452030c004',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  'ff2da630-014e-4792-95f9-a4ba3dffc740',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  'ac728c89-154e-4137-a1de-13a3aa43c26e',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '92783b56-c474-412d-95ca-9b23ee3f0b97',
  '2ddd8341-54fd-4c02-85d6-c0cbd83bc321',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '92783b56-c474-412d-95ca-9b23ee3f0b97',
  '7ebb16b4-7a7c-45e2-bcde-01ed75832393',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  '9d540210-8b3b-4d51-bcff-9c849c2e673c',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  'bf96bcca-eb63-4c8e-8c4b-7f4fb5598c78',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  'c162e45b-8699-43c0-abd6-79cf0b417b60',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  'b532400a-8941-48e2-a5e3-6ed0e9bedee8',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  'aed6e6b8-8afd-44e1-aa76-69da09509c4d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  '63946769-2450-4140-9e83-e27382712a76',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  'ef62ac7a-f3e5-42e1-8fb2-2a5d1ce8253f',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  '99184687-46ed-45ab-b9a4-05a4e1292d83',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  'd3b2f8c7-32e5-4c48-a9e3-5df3ab4f9eb9',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  '34aec6d3-3976-4276-963b-351de527644b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '783143ee-1612-4779-a9d3-1ff0f3f0ca70',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  'aaec7ba9-f4a3-44b7-9096-8fe927a871ab',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '1ad97046-0ec5-43a1-bcb0-49f76d5d04df',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '9318ccc5-6c20-42ac-b44d-b8a6b2f29267',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '2b9f780e-115c-46ce-917a-2a7f57eae922',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '8fe33874-2c12-4a1c-95ed-2c024a6f2942',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  'bbae671a-9511-4c19-9b2d-60674d64376a',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  '59d08124-8600-40ab-a760-5830e8864644',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  '6035531d-253e-41ba-9bc3-6abd0cf01595',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  'f09b89fd-5a95-44b5-915f-edc021cc529b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  'a868f2a6-8f42-4dd8-9971-584c9cad770b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  'de5f3ae3-8097-4e0b-8bfb-272ea023d537',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '34c8e546-bde2-4786-a2ce-05f9fcf6c375',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '16562cdf-e300-4ede-a499-5f1fb954af65',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '77e5f4c8-2924-4eef-a5a5-321186229527',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '08c0ddb5-ce00-4360-8d5f-04a03d2a4afa',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  'eb34c231-9bc0-4045-9551-cda9d31e62ba',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  'd33fb17c-fc08-4fe4-82ab-82d5c646f6c4',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  'e7b2e2fa-8a43-4367-b259-23866de1140d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  '6f5a5ae4-ca5e-4b28-a109-6e621af73533',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  'ec6eb87b-b96f-492f-b111-937468db6c2f',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  '39eb2d5c-cb37-4846-a386-07c2c2d5b197',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  'd10f99a2-1cb8-4eaf-8e7c-21766fb64ddc',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  '6de627ea-06de-47d0-b999-282c3e8dd4e1',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  '3f4735b5-4a92-4691-ad54-c58edbffcb38',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  'c4009219-9120-4134-b1dc-18fbbb98aeba',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  'ad80b645-3b7b-4949-ba24-d81ca8042f68',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '2e9e6a08-bf46-4fea-a956-6065bafbee4c',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '5f2c35a2-d354-41cb-a98f-fdc7a42ad3d6',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '5888483a-b781-4d9b-aad2-bc7deb240acf',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '771e942c-3c09-4d3c-80ac-49f1faaa0d8d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  'bfd39924-7ef0-46c6-b848-af56fbc6a71c',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  'd3418666-a998-47fb-adc3-ba14a2ebce03',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  'acbff4d3-4f5c-49e0-8bef-1366db72603e',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  '3922ed20-b6ec-4085-bbc6-4bff8ac4f9e5',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  '8a9f5ea8-0477-48af-b12f-f928b12cfff8',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  'b1ec9143-ed9a-4078-8d09-d88c8eed45a4',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  'a4dac6dd-ae28-4940-ba42-38fa5ecb3445',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  '34d89f18-3e75-4b2d-813f-649be583f584',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  'd46653b4-dfd2-42db-aeb3-a8c73c71162f',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  'd008eb3b-a8a6-49d3-99ea-b5ba32d77685',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  'c61e9037-cddf-4917-b802-e9822f14ae19',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  'f2196d8c-c6c1-4034-96f3-df6507c4d88e',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8d1afe00-b16f-4698-95f3-64fc2e997f9e',
  'b1b7adf8-32c7-4a00-bdd6-cb25103880ca',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8d1afe00-b16f-4698-95f3-64fc2e997f9e',
  '5edc17e8-5437-4265-a7cf-b1d5fa13d413',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '8d1afe00-b16f-4698-95f3-64fc2e997f9e',
  '446b5c50-dcf3-4fae-a563-3d090baed660',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '7aec561e-bf85-4f1b-afb2-476e32e2a721',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '4448f07e-6d76-4edd-bc9e-2f9ba69fbb88',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '5af7c13a-cf58-4325-a916-618de11423af',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  'a7149945-bfbc-4198-8d5b-ef2b87e3df27',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '664e1dc7-509c-447b-acfb-2a1e0ddbe447',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bcf03792-c296-48d8-baa8-d96261089571',
  'b025c434-60af-4878-8f9b-971961642f46',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bcf03792-c296-48d8-baa8-d96261089571',
  '35f0dec8-983f-4fd1-9521-e2ba71db6614',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bcf03792-c296-48d8-baa8-d96261089571',
  '0ccf8e59-982b-43ff-b8e7-403fce37332a',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bcf03792-c296-48d8-baa8-d96261089571',
  '0d3df1d1-b661-4ca6-8a24-ff6a2db55314',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bcf03792-c296-48d8-baa8-d96261089571',
  'f8dc6a0c-90c7-49f3-9e7d-f40a71f7b79b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bd661084-c670-4910-b568-3a2962a621e5',
  '7ccde0b8-1885-4ec0-b0e1-a6cdec45d235',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bd661084-c670-4910-b568-3a2962a621e5',
  'a4886752-3e1b-4bbb-811e-ac0357ce4914',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bd661084-c670-4910-b568-3a2962a621e5',
  '134df223-2da6-456a-a578-45dbb3a6e4a1',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bd661084-c670-4910-b568-3a2962a621e5',
  'e31a6c26-4df4-43d3-9946-953c9f3028c1',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'bd661084-c670-4910-b568-3a2962a621e5',
  'f2652390-dec2-4af4-9c62-c83ea7ba09e9',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '8a3338c5-e2ec-49a7-9673-a697eeaa8401',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  'eb699b26-23f1-4b27-a293-97c9bdeeda30',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '31603b50-4cef-4a64-8410-49cf05fdaad5',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '61eb9666-1f56-4e83-b756-3aa6dc8b5dde',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  '886e11ad-25c8-43b7-ab12-01eea361f6d9',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '075754fd-1256-42ea-b4c6-39c6c9d52d36',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  '0fc66d00-f116-4c65-97c7-2a12e10b36c8',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '78f99644-e68d-4091-86b5-d2c4d5c63061',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '2dcab342-0829-4e51-8393-7fe727434d87',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  'c4d0682e-a75e-4aae-8a93-e4b96574f347',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  'bf12e017-37b4-4189-aa25-d6a395920f29',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '912fad4c-792d-4e8f-b978-c81564dab69d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '3ea15c7d-274f-4efb-9351-b4e995b58d7c',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  '5eb84b6f-89b7-446b-890f-0a756777831b',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '0cef80af-461f-46fe-8083-57f18385be03',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  'e7b2e2fa-8a43-4367-b259-23866de1140d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  '2dc90091-9cdd-47f5-b3ee-af0e3d39c80d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '569e9198-2138-45d8-9938-73f73b62cd05',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '7aff4cee-6a8f-43c2-9cdf-b375ffe3213f',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '317a298c-a051-46f2-9eb4-1833503fbcf6',
  'ca2e303c-dc21-467f-b36c-ae3f209db04c',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '317a298c-a051-46f2-9eb4-1833503fbcf6',
  'b1ec9143-ed9a-4078-8d09-d88c8eed45a4',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '317a298c-a051-46f2-9eb4-1833503fbcf6',
  'bfd39924-7ef0-46c6-b848-af56fbc6a71c',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '317a298c-a051-46f2-9eb4-1833503fbcf6',
  'ff2416bd-cf9e-4a04-bc71-2814950c3420',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd9ad1bc8-db91-43ba-8371-fe883ab72aa3',
  '67602970-ff8c-4b2d-9b47-5986511a7dac',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd9ad1bc8-db91-43ba-8371-fe883ab72aa3',
  '1ef583b2-2c47-41bf-abf2-84ea8a70b4a5',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'd9ad1bc8-db91-43ba-8371-fe883ab72aa3',
  '7594a33e-0c93-408a-b0bb-f64e0a430c4a',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'e95d3487-5ef2-478c-8035-b878c455e463',
  '2c84b489-35a7-4d87-807d-5a2fbc88bf43',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'b1103cf5-a767-4ee3-aa18-4d914ec74f28',
  '842529d8-0630-465b-b6fa-25347ed4944d',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'b1103cf5-a767-4ee3-aa18-4d914ec74f28',
  'fa28078d-5d53-4cd5-a52f-d1a583714a23',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'b1103cf5-a767-4ee3-aa18-4d914ec74f28',
  'be0a2f3b-2839-4ac1-83bf-17e305ff5776',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  'b1103cf5-a767-4ee3-aa18-4d914ec74f28',
  'd6bacc62-f14c-4bf5-9528-9d6081a9feb1',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  'a488f348-6b51-4209-bf19-6cf987e26e55',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  'a6808cb0-e567-4629-b687-d94495f73dc4',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  '783143ee-1612-4779-a9d3-1ff0f3f0ca70',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  'fd26d92f-775a-4180-b057-f9524ebbe481',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  '4014e784-f847-4788-997c-4fad1f550eb0',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  '34e60201-72bf-467f-8844-f8ac00fa7197',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '4f9bd680-e57f-4338-89b2-c2e87a0f1390',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '06c3b114-a217-4a7b-97a7-447a55b828eb',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '6a9ac331-2ebe-4ed5-b78d-96c9714efd07',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '2f539aae-852e-4f43-9f5c-d12c47135e34',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  'f73b6632-7c84-4606-a8a3-86855c89375e',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO character_schticks (
  character_id, schtick_id,
  created_at, updated_at
) VALUES (
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '96240583-95fe-490c-8724-5a9f953910e3',
  NOW(),
  NOW()
) ON CONFLICT (character_id, schtick_id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '22a352eb-0c0f-4ca6-8ee4-954cf42e62c0',
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  'd54105a3-830a-4516-823a-d7e8e4aee168',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'a5903d3a-205b-4751-a180-651ac77e9eef',
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'c3d5864f-ab24-4e28-aa70-c84e55dba68a',
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '1c454ba1-f55a-4139-bd1d-40db99bbc439',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '80e5318c-b00e-462c-ba12-783e4d656970',
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '1eb4a464-faf7-404d-b623-c0c353e44bd1',
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '92a0c1f7-aafe-4ca7-ba58-162f9c9ffc7a',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '86a0af5a-0b7a-458e-ad45-87ddbaff5fbe',
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  '66c1a79c-a70c-4416-85c9-763c5baa4bb0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '965e010f-8a93-4f4e-ad59-f9575fb2e9b9',
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  '5f240d4d-1fc4-48ba-aa5a-73d7aa64f2fc',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '72e2ebbf-b89b-4127-b587-29d98bf53eb6',
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  '2f406acf-9d8c-42c1-bc8f-ed5983ee30d7',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '3e4fa360-f7db-4c2a-9068-8469d180c10b',
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  'cc3a4cfa-979b-4817-b669-f22864106e37',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'fe4e8023-2630-4132-ba94-8db083b6b125',
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '060fc85a-888a-4d68-9e16-adedcaa0d5db',
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  '1c454ba1-f55a-4139-bd1d-40db99bbc439',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'e110a338-2eaf-4f7c-a944-55962659d3db',
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  '15effb28-cd54-43f4-a7f5-17776339c3dc',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'e9e45c86-a151-4fc1-b497-caeaa0342774',
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  'de55fd8f-7247-4ece-a347-24731b43c32d',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '426f45bb-9404-4714-a350-99eebc4f1778',
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  'cf812427-8794-4307-8554-0e36498a7815',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'cb3dfe84-3815-416c-9d5a-393437c6b18d',
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '7550e7ce-564c-46b5-b6b8-16b55e47fd01',
  'f7d9c375-eee7-47ec-8975-90aefe08000a',
  '7487e8c6-be77-4bea-80b1-d53970136717',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'c8f7bfee-168f-4ca1-be6c-01dd489587a8',
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '7686ea35-1396-4ff3-9ed9-0a2f801db604',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '6338499c-655f-4f8e-ac18-dc2e35d3324f',
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '72ae8aaf-c078-48e6-95d7-f0c5925864ca',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'b78731d3-82af-4bd6-8eed-9c65f5838d14',
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  'b45ac88d-9829-4f11-b34a-72bf0354425c',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '34592897-4a2e-4c6e-9d22-7842198e3d28',
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  '6b28ce0f-7feb-48b5-9b0f-5a4c3c3e7495',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '2571f5a0-dabf-4b9c-bde6-b067431ec08a',
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  '2f406acf-9d8c-42c1-bc8f-ed5983ee30d7',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '53a4b0a1-e1c1-4b99-8ea8-a39e2c0bd27c',
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  'de55fd8f-7247-4ece-a347-24731b43c32d',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'cc01dbba-c88b-4e34-a057-c460376edd1c',
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  'e382cec9-3b64-4f42-b9df-98b05c7f2ff5',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'ca7737c7-3d33-4f06-9c20-565b4b276515',
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  'b45ac88d-9829-4f11-b34a-72bf0354425c',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '064b4be5-970b-4cb9-8507-fad2168c90c3',
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '6b28ce0f-7feb-48b5-9b0f-5a4c3c3e7495',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '711f766d-62ba-422b-bd37-da0f82a0aae5',
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '93fcbc00-83e5-4f1b-8ed5-9f9390ea3ea6',
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  '67ab6c08-84e8-498c-871e-fd403a1cdcff',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '972f4084-e7a9-467a-87d6-070ca14d782c',
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  '96217554-4aa6-4906-8249-b2063d03a0e3',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '317e7b1e-502e-4c12-8194-b7f0cf09641f',
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  'b45ac88d-9829-4f11-b34a-72bf0354425c',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '7796bc49-7765-4918-a977-998134a2056c',
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  'ec3d08d2-5709-4357-9735-47e1cc0b6910',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'abb94f3b-9515-4e8d-ba04-461b699f9b48',
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '1c454ba1-f55a-4139-bd1d-40db99bbc439',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '72a3ddff-5175-402c-9523-aa3076adccc4',
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '311078b9-711e-46a7-8c50-dba829206367',
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '78bb427a-d5c2-4937-a4d2-12dfee5a16f9',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '15b9d04b-421e-4975-a8e5-185f48919be9',
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'ed37c253-4c6a-4713-93e7-65d214f2a8ff',
  'd9ad1bc8-db91-43ba-8371-fe883ab72aa3',
  '89e3ea66-bd13-4ed5-943b-fa5c1ac95a03',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '4ef8a070-1572-48c4-859b-d57c3c6931f5',
  'bcf03792-c296-48d8-baa8-d96261089571',
  '1c454ba1-f55a-4139-bd1d-40db99bbc439',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'c0d7db95-10a5-478d-a40a-cce136c8532b',
  'df233719-e808-4146-aa94-c76efa1d9db4',
  '78bb427a-d5c2-4937-a4d2-12dfee5a16f9',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '03d6fe27-64f4-4137-88fe-62c420620b4c',
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '6a4a9f1c-56d2-4e08-b7c2-99a9d00f1ea3',
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  '1c454ba1-f55a-4139-bd1d-40db99bbc439',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  'ee7c8e99-fda1-4c74-acdb-25374a20d1c6',
  '92783b56-c474-412d-95ca-9b23ee3f0b97',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '12552aa5-f6f0-44cb-89a1-f2a0602c71a3',
  '2c2efc13-84ce-45d5-9549-b5b058b2ebe0',
  '998b1544-3bf0-4907-aa9c-06fb103cdad0',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO carries (
  id, character_id, weapon_id,
  created_at, updated_at
) VALUES (
  '3725c300-39ab-427d-9eea-21659acdcd2b',
  'e95d3487-5ef2-478c-8035-b878c455e463',
  '4b337cb9-316a-4edb-bd17-82f8d476ce13',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '45f5a4d9-80e8-4c3a-b3bd-f5416a3ce7a8',
  'Character',
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  'desktop_edit',
  0.0,
  -311.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '43bdfa8e-4462-4515-a340-c0444c384058',
  'Character',
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  'desktop_edit',
  0.0,
  -230.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '1a162536-d419-4f52-afc4-c3c1303bfba7',
  'Character',
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  'desktop_edit',
  0.0,
  -92.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '5b675fa1-1671-442d-9fb9-39908be665c6',
  'Character',
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  'desktop_edit',
  0.0,
  -129.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '874d2bd9-dada-4566-9f69-35cd49355d2c',
  'Character',
  'ac248717-2f82-44b5-ac39-83b582777a96',
  'desktop_edit',
  0.0,
  -104.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'c34ef044-bce6-40cb-87be-76cc969fe4a2',
  'Character',
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  'desktop_edit',
  0.0,
  -84.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '47df097b-55a1-4015-9fd2-3bc4a89e9acb',
  'Character',
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  'desktop_edit',
  0.0,
  -135.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '74e48a6f-d360-44f1-884a-71e872b9dcaa',
  'Character',
  '8d1afe00-b16f-4698-95f3-64fc2e997f9e',
  'desktop_edit',
  0.0,
  -154.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'e1887558-c881-4a32-844e-aa2fc7a6b51a',
  'Character',
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  'desktop_edit',
  0.0,
  -202.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'd8c5f19e-5973-4ecf-bfa2-6d94e7acd038',
  'Character',
  '23bde1d7-2561-4418-bd1b-47920351338d',
  'desktop_edit',
  0.0,
  -231.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'becc445d-bbae-4073-893b-fe64fb7b1722',
  'Character',
  'f7d9c375-eee7-47ec-8975-90aefe08000a',
  'desktop_edit',
  0.0,
  -101.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'caf88f24-d921-4d0c-8d5b-0451ad2408b0',
  'Character',
  '317a298c-a051-46f2-9eb4-1833503fbcf6',
  'desktop_edit',
  0.0,
  -136.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '93dfbe22-eeb1-455c-8582-ebb134cbcfcc',
  'Character',
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  'desktop_edit',
  0.0,
  -90.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '9110f0d1-3cfd-46a1-ab37-ad1e88c48205',
  'Character',
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  'desktop_edit',
  0.0,
  -107.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '512e22a5-0bd5-449e-9cbe-81c1a9361e5d',
  'Character',
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  'desktop_edit',
  0.0,
  -96.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '7ed00ab9-441c-4174-8caf-7ab5ea00e528',
  'Character',
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  'desktop_edit',
  0.0,
  -138.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '4588bf81-c900-4126-acd4-976f434d85be',
  'Character',
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  'desktop_edit',
  0.0,
  -216.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '43b7b878-94e7-4901-8f02-9af91635972d',
  'Character',
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  'desktop_edit',
  0.0,
  -219.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '4358827b-6f5d-43d5-93c1-76fe1f6af3d9',
  'Character',
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  'desktop_edit',
  0.0,
  -163.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'e8384731-62a4-4d6e-b388-00e452e965ff',
  'Character',
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  'desktop_edit',
  0.0,
  -148.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '5e1156f6-8abb-430a-acfd-5a2e6e4f2490',
  'Character',
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  'desktop_edit',
  0.0,
  -137.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '23d4612b-4345-40c6-b5e8-dbd09a4e4a8e',
  'Character',
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  'desktop_edit',
  0.0,
  -120.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '9b3eb33c-d7f0-4be5-a3c2-9586b7ea2c50',
  'Character',
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  'desktop_edit',
  0.0,
  -220.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'e9416f3d-393e-49b5-aa0e-134384a47e02',
  'Character',
  'd9ad1bc8-db91-43ba-8371-fe883ab72aa3',
  'desktop_edit',
  0.0,
  -144.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'b72b0c01-1a24-4c12-9a3f-755c6e60a2aa',
  'Character',
  'bcf03792-c296-48d8-baa8-d96261089571',
  'desktop_edit',
  0.0,
  -244.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '5ce3caf3-bfad-43d1-bf72-0dbff6ca642b',
  'Character',
  'df233719-e808-4146-aa94-c76efa1d9db4',
  'desktop_edit',
  0.0,
  -148.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'e938a4df-0cb7-4747-8541-92ccde6a9453',
  'Character',
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  'desktop_edit',
  0.0,
  -106.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '67c9cf47-fed8-41d7-9633-cf90b95d5943',
  'Character',
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  'desktop_edit',
  0.0,
  -133.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '99ed73c8-7cdf-4d72-803f-6d0e6e01c131',
  'Character',
  'e95d3487-5ef2-478c-8035-b878c455e463',
  'desktop_edit',
  0.0,
  -110.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'eaeca885-d04a-4b7d-a9c7-45022b3fe679',
  'Character',
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  'desktop_edit',
  0.0,
  -204.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '7f2d27e2-037e-44d3-9cfd-6c47d46620cf',
  'Character',
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  'desktop_edit',
  0.0,
  -135.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '8535168b-9fe9-4244-848e-9e420f2836f9',
  'Character',
  '92783b56-c474-412d-95ca-9b23ee3f0b97',
  'desktop_edit',
  0.0,
  -131.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'c5c4633b-435d-4337-9562-c6073155b660',
  'Character',
  '2c2efc13-84ce-45d5-9549-b5b058b2ebe0',
  'desktop_edit',
  0.0,
  -174.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '4fea6102-0d33-4222-a2b7-393947c22995',
  'Character',
  'b1103cf5-a767-4ee3-aa18-4d914ec74f28',
  'desktop_edit',
  0.0,
  -250.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '091c295f-a56a-4772-9da2-fd3500c84781',
  'Character',
  'bd661084-c670-4910-b568-3a2962a621e5',
  'desktop_edit',
  0.0,
  -264.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '3e9011dd-80ac-4ce2-8f76-5095d271096b',
  'Faction',
  'd12ebf38-6bf4-485d-ab01-36e71e99306a',
  'desktop_entity',
  0.0,
  -150.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'ec2d82a4-a047-4a19-9b56-b6071142ebb6',
  'Faction',
  '9afef0d9-233c-4696-b237-aed0515e0500',
  'desktop_entity',
  0.0,
  -46.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '338bb83f-fd4f-4308-9b82-ae6261b7bc03',
  'Faction',
  '50a7bc5c-ca36-48b7-a17b-5698c2e1958e',
  'desktop_entity',
  0.0,
  -276.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'd4b2755c-9f06-4df5-b982-00746a913e0d',
  'Faction',
  '8a2a13dc-447f-4e71-98fd-732c8d65be78',
  'desktop_entity',
  0.0,
  -47.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '3ced78ed-c84c-489b-aaa5-dcc4c4fa7906',
  'Character',
  '67f709a8-521f-48b5-a3d6-cee40868236a',
  'desktop_edit',
  0.0,
  -108.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '3e702810-6585-4b0c-bd5f-5b0f632d46ba',
  'Character',
  'f0310e8e-871f-46c5-8497-f9e484824281',
  'desktop_edit',
  0.0,
  -212.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '5b6db8cd-ea84-4d66-830d-96344d1be103',
  'Faction',
  'f9c89687-9813-4c50-98fb-ceecfcc5e335',
  'desktop_entity',
  0.0,
  -331.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '725bef74-869c-4795-ad92-720fba18a873',
  'Faction',
  '6bc3abe7-2890-432f-a397-89c763f54d18',
  'desktop_entity',
  0.0,
  -259.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '6ce66614-5820-4c99-a728-a350fe586596',
  'Character',
  'aaf89162-4329-4924-9141-dd8ba02c13a8',
  'desktop_edit',
  0.0,
  -148.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'a6a31f7e-8358-4c74-8dad-9318f82008a2',
  'Character',
  '7a367c9d-ad7f-4bc8-9050-30a58a9e4e99',
  'desktop_edit',
  0.0,
  -189.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '22ffb046-43da-40a6-98e7-2fea50ce93f4',
  'Character',
  '3947d2d8-163a-4bdd-83e8-0de8f751e861',
  'desktop_edit',
  0.0,
  -183.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'c3eef46b-d1f7-4dac-8bc4-1a94884a68ef',
  'Faction',
  'c2c5b7cc-0c64-4866-97c1-b1c9b0e8c457',
  'desktop_entity',
  0.0,
  -215.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '05ff6b4a-a25f-4981-8088-344b01e63cdd',
  'Faction',
  'f1b59811-a684-4d3f-a07b-4fcafc79eb7d',
  'desktop_entity',
  0.0,
  -183.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '212786af-6567-4c50-8608-0947825b527c',
  'Faction',
  'ce40d0a1-ed7c-4122-a219-996e46425115',
  'desktop_entity',
  0.0,
  -240.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '1e55785d-78b0-41df-a405-2c096b4cb338',
  'Faction',
  '954edb9f-afd2-4df8-985d-6756594d0d94',
  'desktop_entity',
  0.0,
  -236.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  '46dd0523-85c4-40ba-9c87-070e509a2c05',
  'Faction',
  'c52de513-622e-4bda-a88e-cec2a5c13ddb',
  'desktop_entity',
  0.0,
  -222.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO image_positions (
  id, positionable_type, positionable_id, context,
  x_position, y_position, style_overrides,
  created_at, updated_at
) VALUES (
  'dad11a40-07fe-4a20-91fb-f637b4f84f8b',
  'Faction',
  'c44f7eaf-425b-497f-b278-92a3bc612e55',
  'desktop_entity',
  0.0,
  -128.0,
  '{}',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '304',
  '3f8ba9fbw2ofb6a7h4pjvott32u8',
  'Archer.png',
  'image/png',
  '{"fileId":"68ad94135c7cd75eb83fabca","name":"Archer_ZRW-zqtCC.png","size":3343046,"versionInfo":{"id":"68ad94135c7cd75eb83fabca","name":"Version 1"},"filePath":"/Archer_ZRW-zqtCC.png","url":"https://ik.imagekit.io/nvqgwnjgv/Archer_ZRW-zqtCC.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Archer_ZRW-zqtCC.png","AITags":null,"description":null}',
  'imagekitio',
  3343046,
  'eEdoI+rQWjoOCniURo0ZxQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '305',
  'ew9hczw6fls4y7rbdb19qopqwh05',
  'Bandit.png',
  'image/png',
  '{"fileId":"68ad94715c7cd75eb842ab6c","name":"Bandit_GsvWOhYFk.png","size":2865206,"versionInfo":{"id":"68ad94715c7cd75eb842ab6c","name":"Version 1"},"filePath":"/Bandit_GsvWOhYFk.png","url":"https://ik.imagekit.io/nvqgwnjgv/Bandit_GsvWOhYFk.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Bandit_GsvWOhYFk.png","AITags":null,"description":null}',
  'imagekitio',
  2865206,
  'PGDFUkXQayAaPrvHenMnAA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '306',
  '79pl01u53meneqn1wtqf0d1nkmjb',
  'Big Bruiser.png',
  'image/png',
  '{"fileId":"68ad94865c7cd75eb84370fe","name":"Big_Bruiser_1Xqe8U7fVY.png","size":2872232,"versionInfo":{"id":"68ad94865c7cd75eb84370fe","name":"Version 1"},"filePath":"/Big_Bruiser_1Xqe8U7fVY.png","url":"https://ik.imagekit.io/nvqgwnjgv/Big_Bruiser_1Xqe8U7fVY.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Big_Bruiser_1Xqe8U7fVY.png","AITags":null,"description":null}',
  'imagekitio',
  2872232,
  'vTyDl0Nedu52aTiLYrO5Bg==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '307',
  'qy9bpd6qzpf94ckvoiw82ga18da1',
  'Bodyguard.png',
  'image/png',
  '{"fileId":"68ad94c05c7cd75eb84566e5","name":"Bodyguard_68rTwKZZ8.png","size":2907227,"versionInfo":{"id":"68ad94c05c7cd75eb84566e5","name":"Version 1"},"filePath":"/Bodyguard_68rTwKZZ8.png","url":"https://ik.imagekit.io/nvqgwnjgv/Bodyguard_68rTwKZZ8.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Bodyguard_68rTwKZZ8.png","AITags":null,"description":null}',
  'imagekitio',
  2907227,
  'JCwmBSGmr3plXZR1cwcdvQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '308',
  'vckobk8orieknyr81e62cy8u6lk8',
  'Cyborg.png',
  'image/png',
  '{"fileId":"68ad94e85c7cd75eb846a60a","name":"Cyborg_NxxIsyjaP.png","size":2848420,"versionInfo":{"id":"68ad94e85c7cd75eb846a60a","name":"Version 1"},"filePath":"/Cyborg_NxxIsyjaP.png","url":"https://ik.imagekit.io/nvqgwnjgv/Cyborg_NxxIsyjaP.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Cyborg_NxxIsyjaP.png","AITags":null,"description":null}',
  'imagekitio',
  2848420,
  'WdZYsFD7g9uZZ2PB7eKPLQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '309',
  'mbliofdgw9sb2lptv15pzg2toz0g',
  'Drifter.png',
  'image/png',
  '{"fileId":"68ad95165c7cd75eb8482ba0","name":"Drifter_VDrjLiU4P.png","size":3172309,"versionInfo":{"id":"68ad95165c7cd75eb8482ba0","name":"Version 1"},"filePath":"/Drifter_VDrjLiU4P.png","url":"https://ik.imagekit.io/nvqgwnjgv/Drifter_VDrjLiU4P.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Drifter_VDrjLiU4P.png","AITags":null,"description":null}',
  'imagekitio',
  3172309,
  'ApNipPXy8yKXVTo7l21k3A==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '310',
  '3eluch1ckzd0vvbw4tdfxeneiv4v',
  'Driver.png',
  'image/png',
  '{"fileId":"68ad95365c7cd75eb8492951","name":"Driver_WBj1QY2PK.png","size":3347881,"versionInfo":{"id":"68ad95365c7cd75eb8492951","name":"Version 1"},"filePath":"/Driver_WBj1QY2PK.png","url":"https://ik.imagekit.io/nvqgwnjgv/Driver_WBj1QY2PK.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Driver_WBj1QY2PK.png","AITags":null,"description":null}',
  'imagekitio',
  3347881,
  'g7jCk6qeHP0P4hR/EisAnw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '311',
  'r81uxx1e7u05v397qmuur7n8bm0p',
  'Everyday Hero.png',
  'image/png',
  '{"fileId":"68ad95535c7cd75eb84a0661","name":"Everyday_Hero_ZP6oWDxOH.png","size":2953913,"versionInfo":{"id":"68ad95535c7cd75eb84a0661","name":"Version 1"},"filePath":"/Everyday_Hero_ZP6oWDxOH.png","url":"https://ik.imagekit.io/nvqgwnjgv/Everyday_Hero_ZP6oWDxOH.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Everyday_Hero_ZP6oWDxOH.png","AITags":null,"description":null}',
  'imagekitio',
  2953913,
  'OMOafVxchgD/2cd87rEgcA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '312',
  'ejvwv34lxbybgrbtram1qtbsc8fo',
  'Exorcist Monk.png',
  'image/png',
  '{"fileId":"68ad959a5c7cd75eb84ca64a","name":"Exorcist_Monk_4NiZhLDNH.png","size":3261093,"versionInfo":{"id":"68ad959a5c7cd75eb84ca64a","name":"Version 1"},"filePath":"/Exorcist_Monk_4NiZhLDNH.png","url":"https://ik.imagekit.io/nvqgwnjgv/Exorcist_Monk_4NiZhLDNH.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Exorcist_Monk_4NiZhLDNH.png","AITags":null,"description":null}',
  'imagekitio',
  3261093,
  'xWBbcnlUcZFVEOW6qrqG6w==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '313',
  'wa9uvnifxzoayilsn7zejnd964tp',
  'Full-Metal Nutball.png',
  'image/png',
  '{"fileId":"68ad95b65c7cd75eb84e88fe","name":"Full-Metal_Nutball_oPZHL34c-o.png","size":3482062,"versionInfo":{"id":"68ad95b65c7cd75eb84e88fe","name":"Version 1"},"filePath":"/Full-Metal_Nutball_oPZHL34c-o.png","url":"https://ik.imagekit.io/nvqgwnjgv/Full-Metal_Nutball_oPZHL34c-o.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Full-Metal_Nutball_oPZHL34c-o.png","AITags":null,"description":null}',
  'imagekitio',
  3482062,
  'rIROZLaLWlYx3QqEy+Yv6Q==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '314',
  'v5gmx6ecajhpxu2bkppxyxp8dzpp',
  'Gambler.png',
  'image/png',
  '{"fileId":"68ad95d45c7cd75eb850cd8f","name":"Gambler_x8gwcAi33V.png","size":3229189,"versionInfo":{"id":"68ad95d45c7cd75eb850cd8f","name":"Version 1"},"filePath":"/Gambler_x8gwcAi33V.png","url":"https://ik.imagekit.io/nvqgwnjgv/Gambler_x8gwcAi33V.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Gambler_x8gwcAi33V.png","AITags":null,"description":null}',
  'imagekitio',
  3229189,
  'k+xWRZ54K/yfe9D5xkP6Tw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '317',
  'unkblm4bcrkiyozis81uhg9i4kej',
  'Ghost.png',
  'image/png',
  '{"fileId":"68ad970e5c7cd75eb8606fcc","name":"Ghost_X64N93uVK.png","size":2977235,"versionInfo":{"id":"68ad970e5c7cd75eb8606fcc","name":"Version 1"},"filePath":"/Ghost_X64N93uVK.png","url":"https://ik.imagekit.io/nvqgwnjgv/Ghost_X64N93uVK.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Ghost_X64N93uVK.png","AITags":null,"description":null}',
  'imagekitio',
  2977235,
  '7kI7o0Dy/L2u7S2ZH2GTFw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '318',
  'rd996ynuhqwm8jkib7sh3fpygom6',
  'Highway Ronin.png',
  'image/png',
  '{"fileId":"68ad97795c7cd75eb863d8c1","name":"Highway_Ronin_WRev4WOp_.png","size":2978629,"versionInfo":{"id":"68ad97795c7cd75eb863d8c1","name":"Version 1"},"filePath":"/Highway_Ronin_WRev4WOp_.png","url":"https://ik.imagekit.io/nvqgwnjgv/Highway_Ronin_WRev4WOp_.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Highway_Ronin_WRev4WOp_.png","AITags":null,"description":null}',
  'imagekitio',
  2978629,
  'yjYWU/u0CuZuPjvcPnSKTQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '319',
  'tcn3ttxo5401q43rxhr77x2fv4uz',
  'Karate Cop.png',
  'image/png',
  '{"fileId":"68ad97cc5c7cd75eb866675c","name":"Karate_Cop_UcSmAlAWMJ.png","size":2759124,"versionInfo":{"id":"68ad97cc5c7cd75eb866675c","name":"Version 1"},"filePath":"/Karate_Cop_UcSmAlAWMJ.png","url":"https://ik.imagekit.io/nvqgwnjgv/Karate_Cop_UcSmAlAWMJ.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Karate_Cop_UcSmAlAWMJ.png","AITags":null,"description":null}',
  'imagekitio',
  2759124,
  'Z6NzsVePBr/b6xeOTAAUWw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '320',
  'b46wl8kn04ybofrj985oa1skrk29',
  'Killer.png',
  'image/png',
  '{"fileId":"68ad97e45c7cd75eb8676593","name":"Killer_7wAFQSERK.png","size":3480883,"versionInfo":{"id":"68ad97e45c7cd75eb8676593","name":"Version 1"},"filePath":"/Killer_7wAFQSERK.png","url":"https://ik.imagekit.io/nvqgwnjgv/Killer_7wAFQSERK.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Killer_7wAFQSERK.png","AITags":null,"description":null}',
  'imagekitio',
  3480883,
  'FymIX3LQi+YNJVBL/trXPw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '321',
  't6sco0dh9qig8munfgw241jqnkaq',
  'Magic Cop.png',
  'image/png',
  '{"fileId":"68ad98155c7cd75eb868e319","name":"Magic_Cop_Vj0e_-HWE1.png","size":3148483,"versionInfo":{"id":"68ad98155c7cd75eb868e319","name":"Version 1"},"filePath":"/Magic_Cop_Vj0e_-HWE1.png","url":"https://ik.imagekit.io/nvqgwnjgv/Magic_Cop_Vj0e_-HWE1.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Magic_Cop_Vj0e_-HWE1.png","AITags":null,"description":null}',
  'imagekitio',
  3148483,
  'tkKffafpJYkNdk6xG9SVHA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '322',
  'oasfr0rmp2k5yfcbxolm8x7plrg0',
  'Martial Artist.png',
  'image/png',
  '{"fileId":"68ad982c5c7cd75eb86996da","name":"Martial_Artist_wm6oQXDYi.png","size":3212755,"versionInfo":{"id":"68ad982c5c7cd75eb86996da","name":"Version 1"},"filePath":"/Martial_Artist_wm6oQXDYi.png","url":"https://ik.imagekit.io/nvqgwnjgv/Martial_Artist_wm6oQXDYi.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Martial_Artist_wm6oQXDYi.png","AITags":null,"description":null}',
  'imagekitio',
  3212755,
  'JqXX4IXwD2LQMGdbAURazw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '323',
  'gr6g2o5psddp5vdnnj000ieklxcf',
  'Gene Freak.png',
  'image/png',
  '{"fileId":"68ad98575c7cd75eb86adc96","name":"Gene_Freak_GMw5LRhKP.png","size":2923394,"versionInfo":{"id":"68ad98575c7cd75eb86adc96","name":"Version 1"},"filePath":"/Gene_Freak_GMw5LRhKP.png","url":"https://ik.imagekit.io/nvqgwnjgv/Gene_Freak_GMw5LRhKP.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Gene_Freak_GMw5LRhKP.png","AITags":null,"description":null}',
  'imagekitio',
  2923394,
  'Mb5PeiotdrEBmVaGedTS9g==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '324',
  '57rr353nzo5rhmlsrgdp8ulw6r7z',
  'Ex-Special Forces.png',
  'image/png',
  '{"fileId":"68ad985f5c7cd75eb86b2058","name":"Ex-Special_Forces_V0KO0ma6Q.png","size":3244860,"versionInfo":{"id":"68ad985f5c7cd75eb86b2058","name":"Version 1"},"filePath":"/Ex-Special_Forces_V0KO0ma6Q.png","url":"https://ik.imagekit.io/nvqgwnjgv/Ex-Special_Forces_V0KO0ma6Q.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Ex-Special_Forces_V0KO0ma6Q.png","AITags":null,"description":null}',
  'imagekitio',
  3244860,
  '3K404SPGazRjp7Jzm8rKnQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '325',
  'mq19cu1gbxv2xb18v0ufn67bgixb',
  'Masked Avenger.png',
  'image/png',
  '{"fileId":"68ad987d5c7cd75eb86c0a71","name":"Masked_Avenger_tPz4TLfL-.png","size":2985675,"versionInfo":{"id":"68ad987d5c7cd75eb86c0a71","name":"Version 1"},"filePath":"/Masked_Avenger_tPz4TLfL-.png","url":"https://ik.imagekit.io/nvqgwnjgv/Masked_Avenger_tPz4TLfL-.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Masked_Avenger_tPz4TLfL-.png","AITags":null,"description":null}',
  'imagekitio',
  2985675,
  'VAqTGJBm+8wWkFW3z2kIWQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '326',
  '6cm98hinsxfiuyy3zje5gogot9re',
  'Maverick Cop.png',
  'image/png',
  '{"fileId":"68ad98935c7cd75eb86cbc30","name":"Maverick_Cop_oVSKaQMHj.png","size":3061395,"versionInfo":{"id":"68ad98935c7cd75eb86cbc30","name":"Version 1"},"filePath":"/Maverick_Cop_oVSKaQMHj.png","url":"https://ik.imagekit.io/nvqgwnjgv/Maverick_Cop_oVSKaQMHj.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Maverick_Cop_oVSKaQMHj.png","AITags":null,"description":null}',
  'imagekitio',
  3061395,
  'pJZCyOoL0ZmR7EjPstij6w==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '327',
  'vn97dnmlcsb0ur77igmutdhhtd9f',
  'Ninja.png',
  'image/png',
  '{"fileId":"68ad98ae5c7cd75eb86d8020","name":"Ninja_t0MQBmoN2.png","size":2812650,"versionInfo":{"id":"68ad98ae5c7cd75eb86d8020","name":"Version 1"},"filePath":"/Ninja_t0MQBmoN2.png","url":"https://ik.imagekit.io/nvqgwnjgv/Ninja_t0MQBmoN2.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Ninja_t0MQBmoN2.png","AITags":null,"description":null}',
  'imagekitio',
  2812650,
  'YYghXqqmxPhTn6mHz1WSPw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '328',
  '2vtwrgh823ifpfffhd2crwov86fq',
  'Old Master.png',
  'image/png',
  '{"fileId":"68ad98cb5c7cd75eb86e5b8b","name":"Old_Master_Y2SF8Kv9v.png","size":3308722,"versionInfo":{"id":"68ad98cb5c7cd75eb86e5b8b","name":"Version 1"},"filePath":"/Old_Master_Y2SF8Kv9v.png","url":"https://ik.imagekit.io/nvqgwnjgv/Old_Master_Y2SF8Kv9v.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Old_Master_Y2SF8Kv9v.png","AITags":null,"description":null}',
  'imagekitio',
  3308722,
  'u14ugsIFIp9CI1n0zz9d+Q==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '329',
  '1yvjn9gqdzwh6kxq1tx5clcahwqv',
  'Private Investigator.png',
  'image/png',
  '{"fileId":"68ad98eb5c7cd75eb86f7530","name":"Private_Investigator_TpRwpVpiB.png","size":2976360,"versionInfo":{"id":"68ad98eb5c7cd75eb86f7530","name":"Version 1"},"filePath":"/Private_Investigator_TpRwpVpiB.png","url":"https://ik.imagekit.io/nvqgwnjgv/Private_Investigator_TpRwpVpiB.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Private_Investigator_TpRwpVpiB.png","AITags":null,"description":null}',
  'imagekitio',
  2976360,
  'D0C46lQxzZ80W8qkxd079g==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '330',
  'rzi08kaammf67z3kbo58bfjbhn7m',
  'Redeemed Pirate.png',
  'image/png',
  '{"fileId":"68ad99015c7cd75eb87015dd","name":"Redeemed_Pirate_Si_t1NuWW.png","size":3344810,"versionInfo":{"id":"68ad99015c7cd75eb87015dd","name":"Version 1"},"filePath":"/Redeemed_Pirate_Si_t1NuWW.png","url":"https://ik.imagekit.io/nvqgwnjgv/Redeemed_Pirate_Si_t1NuWW.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Redeemed_Pirate_Si_t1NuWW.png","AITags":null,"description":null}',
  'imagekitio',
  3344810,
  'L/FlaujBBM1jIKIXpUmQjw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '331',
  'gj75buwkom1goxrhkffoq0n2e29d',
  'Scrappy Kid.png',
  'image/png',
  '{"fileId":"68ad99645c7cd75eb873c7ff","name":"Scrappy_Kid_tvvhehmwj.png","size":3099725,"versionInfo":{"id":"68ad99645c7cd75eb873c7ff","name":"Version 1"},"filePath":"/Scrappy_Kid_tvvhehmwj.png","url":"https://ik.imagekit.io/nvqgwnjgv/Scrappy_Kid_tvvhehmwj.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Scrappy_Kid_tvvhehmwj.png","AITags":null,"description":null}',
  'imagekitio',
  3099725,
  'adZMmir5OTOcnGHuNInbCA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '332',
  '7sw7jw0yexv28tm1ss9u8n9g0spw',
  'Sifu.png',
  'image/png',
  '{"fileId":"68ad99ab5c7cd75eb8763384","name":"Sifu_luGBqT3sr_.png","size":3274167,"versionInfo":{"id":"68ad99ab5c7cd75eb8763384","name":"Version 1"},"filePath":"/Sifu_luGBqT3sr_.png","url":"https://ik.imagekit.io/nvqgwnjgv/Sifu_luGBqT3sr_.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Sifu_luGBqT3sr_.png","AITags":null,"description":null}',
  'imagekitio',
  3274167,
  'fXY1ziK9h1i0c3j07mD0bg==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '333',
  'aoq9gg1fqjdjz1qfviv87bovab7o',
  'Supernatural Creature.png',
  'image/png',
  '{"fileId":"68ad99da5c7cd75eb877bf3b","name":"Supernatural_Creature_bhUAJkBrv.png","size":3416558,"versionInfo":{"id":"68ad99da5c7cd75eb877bf3b","name":"Version 1"},"filePath":"/Supernatural_Creature_bhUAJkBrv.png","url":"https://ik.imagekit.io/nvqgwnjgv/Supernatural_Creature_bhUAJkBrv.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Supernatural_Creature_bhUAJkBrv.png","AITags":null,"description":null}',
  'imagekitio',
  3416558,
  'KjWqQtaoVE3F0auZhbDo+Q==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '334',
  '8eatovf77ii2inrnr3d93s48dtp5',
  'Spy.png',
  'image/png',
  '{"fileId":"68ad99f35c7cd75eb878a284","name":"Spy_z5n_dxhRg.png","size":3096789,"versionInfo":{"id":"68ad99f35c7cd75eb878a284","name":"Version 1"},"filePath":"/Spy_z5n_dxhRg.png","url":"https://ik.imagekit.io/nvqgwnjgv/Spy_z5n_dxhRg.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Spy_z5n_dxhRg.png","AITags":null,"description":null}',
  'imagekitio',
  3096789,
  'v724atwSaWQh9zeABlpq6g==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '335',
  'xnuj02dlc7djl9948uqm76dw019f',
  'Sorcerer.png',
  'image/png',
  '{"fileId":"68ad9a045c7cd75eb879286c","name":"Sorcerer_ByEi67FTL.png","size":3282656,"versionInfo":{"id":"68ad9a045c7cd75eb879286c","name":"Version 1"},"filePath":"/Sorcerer_ByEi67FTL.png","url":"https://ik.imagekit.io/nvqgwnjgv/Sorcerer_ByEi67FTL.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Sorcerer_ByEi67FTL.png","AITags":null,"description":null}',
  'imagekitio',
  3282656,
  'HsNidaTmTdmKDrkNKUUGOQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '336',
  'n35yd3k8zma7wmv265rmmp5hr653',
  'Sword Master.png',
  'image/png',
  '{"fileId":"68ad9a2b5c7cd75eb87a69f9","name":"Sword_Master_VYh1Vt2XZ.png","size":3560925,"versionInfo":{"id":"68ad9a2b5c7cd75eb87a69f9","name":"Version 1"},"filePath":"/Sword_Master_VYh1Vt2XZ.png","url":"https://ik.imagekit.io/nvqgwnjgv/Sword_Master_VYh1Vt2XZ.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Sword_Master_VYh1Vt2XZ.png","AITags":null,"description":null}',
  'imagekitio',
  3560925,
  'NqdVz45hM5N4jE7ff27nYQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '337',
  'u6tlwn0xmjujtw9yk5qqn8fmohip',
  'Thief.png',
  'image/png',
  '{"fileId":"68ad9a385c7cd75eb87acf68","name":"Thief_9jyirWew4.png","size":2731660,"versionInfo":{"id":"68ad9a385c7cd75eb87acf68","name":"Version 1"},"filePath":"/Thief_9jyirWew4.png","url":"https://ik.imagekit.io/nvqgwnjgv/Thief_9jyirWew4.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Thief_9jyirWew4.png","AITags":null,"description":null}',
  'imagekitio',
  2731660,
  'q1GuHgZ5caHc3SSkBwQrgQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '338',
  'kf7qt9qj0c4tod5w357m7y672sj2',
  'Two-Fisted Archaeologist.png',
  'image/png',
  '{"fileId":"68ad9a425c7cd75eb87b0609","name":"Two-Fisted_Archaeologist___CUtxSbL.png","size":3040166,"versionInfo":{"id":"68ad9a425c7cd75eb87b0609","name":"Version 1"},"filePath":"/Two-Fisted_Archaeologist___CUtxSbL.png","url":"https://ik.imagekit.io/nvqgwnjgv/Two-Fisted_Archaeologist___CUtxSbL.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Two-Fisted_Archaeologist___CUtxSbL.png","AITags":null,"description":null}',
  'imagekitio',
  3040166,
  '/GtvTohj1+o2NBxz9K4z7Q==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '339',
  'uwhm8y84fejyywgrf37ha3w6pw8k',
  'Transformed Dragon.png',
  'image/png',
  '{"fileId":"68ad9a4f5c7cd75eb87b5286","name":"Transformed_Dragon_EyuLOBslUH.png","size":3718772,"versionInfo":{"id":"68ad9a4f5c7cd75eb87b5286","name":"Version 1"},"filePath":"/Transformed_Dragon_EyuLOBslUH.png","url":"https://ik.imagekit.io/nvqgwnjgv/Transformed_Dragon_EyuLOBslUH.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Transformed_Dragon_EyuLOBslUH.png","AITags":null,"description":null}',
  'imagekitio',
  3718772,
  'KX4SDDEtM1UPcxS27XKxmA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '340',
  'xfw1h0y7es7imfpny1vez18f5m5k',
  'Transformed Crab.png',
  'image/png',
  '{"fileId":"68ad9a5a5c7cd75eb87bac09","name":"Transformed_Crab_NYbNoinI8.png","size":2922834,"versionInfo":{"id":"68ad9a5a5c7cd75eb87bac09","name":"Version 1"},"filePath":"/Transformed_Crab_NYbNoinI8.png","url":"https://ik.imagekit.io/nvqgwnjgv/Transformed_Crab_NYbNoinI8.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Transformed_Crab_NYbNoinI8.png","AITags":null,"description":null}',
  'imagekitio',
  2922834,
  'OnnIivOPDBbHH58VbrJ1XQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '346',
  'zxq54n7yjcjtjrkf1y30cpt7k59n',
  'Future Wasteland.png',
  'image/png',
  '{"fileId":"68aefe445c7cd75eb8384e7b","name":"Future_Wasteland_9iqO_icSr.png","size":3246348,"versionInfo":{"id":"68aefe445c7cd75eb8384e7b","name":"Version 1"},"filePath":"/Future_Wasteland_9iqO_icSr.png","url":"https://ik.imagekit.io/nvqgwnjgv/Future_Wasteland_9iqO_icSr.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Future_Wasteland_9iqO_icSr.png","AITags":null,"description":null}',
  'imagekitio',
  3246348,
  '/mcYbb34DB9ngY+Yro7wdQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '348',
  '4h2k99zzit2z7y536l58902xfxud',
  'Ancient Juncture.png',
  'image/png',
  '{"fileId":"68aefebd5c7cd75eb83bda68","name":"Ancient_Juncture_UcVVDiaIp.png","size":2513934,"versionInfo":{"id":"68aefebd5c7cd75eb83bda68","name":"Version 1"},"filePath":"/Ancient_Juncture_UcVVDiaIp.png","url":"https://ik.imagekit.io/nvqgwnjgv/Ancient_Juncture_UcVVDiaIp.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Ancient_Juncture_UcVVDiaIp.png","AITags":null,"description":null}',
  'imagekitio',
  2513934,
  'G8jD5GbJLeWqE56smm+49g==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '349',
  'ev9uzkfo20ihjmfj3dhgxjk7lv4h',
  'Past Juncture.png',
  'image/png',
  '{"fileId":"68aefed45c7cd75eb83c9248","name":"Past_Juncture_2XP_nltPx.png","size":3069949,"versionInfo":{"id":"68aefed45c7cd75eb83c9248","name":"Version 1"},"filePath":"/Past_Juncture_2XP_nltPx.png","url":"https://ik.imagekit.io/nvqgwnjgv/Past_Juncture_2XP_nltPx.png","fileType":"image","height":1024,"width":1536,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Past_Juncture_2XP_nltPx.png","AITags":null,"description":null}',
  'imagekitio',
  3069949,
  'OzjIusGKlJ+f2XxI7FX8vg==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '350',
  'pr4zianf1pwn343oqgb6i0ertbh7',
  'Modern Juncture.png',
  'image/png',
  '{"fileId":"68aefee35c7cd75eb83d150a","name":"Modern_Juncture_ciQykk6aG.png","size":2147004,"versionInfo":{"id":"68aefee35c7cd75eb83d150a","name":"Version 1"},"filePath":"/Modern_Juncture_ciQykk6aG.png","url":"https://ik.imagekit.io/nvqgwnjgv/Modern_Juncture_ciQykk6aG.png","fileType":"image","height":1024,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Modern_Juncture_ciQykk6aG.png","AITags":null,"description":null}',
  'imagekitio',
  2147004,
  'YP9qU114cdtLskzceKqGzg==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '352',
  'rrxrbg5d3xlmald3vaupdrxjnuu3',
  'General Grundle.png',
  'image/png',
  '{"fileId":"68af01945c7cd75eb8535b12","name":"General_Grundle_NEVqZeL4y6.png","size":2930254,"versionInfo":{"id":"68af01945c7cd75eb8535b12","name":"Version 1"},"filePath":"/General_Grundle_NEVqZeL4y6.png","url":"https://ik.imagekit.io/nvqgwnjgv/General_Grundle_NEVqZeL4y6.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/General_Grundle_NEVqZeL4y6.png","AITags":null,"description":null}',
  'imagekitio',
  2930254,
  'KrsXO21OEbjk5gpt8R2S6w==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '353',
  'r6d0iymwwtqnrt5o3482ifr0qij8',
  'Netherworld.png',
  'image/png',
  '{"fileId":"68af02f75c7cd75eb85f1367","name":"Netherworld_p3-kxc2f_.png","size":2510947,"versionInfo":{"id":"68af02f75c7cd75eb85f1367","name":"Version 1"},"filePath":"/Netherworld_p3-kxc2f_.png","url":"https://ik.imagekit.io/nvqgwnjgv/Netherworld_p3-kxc2f_.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Netherworld_p3-kxc2f_.png","AITags":null,"description":null}',
  'imagekitio',
  2510947,
  'lquQg+eBER82h6WXMX6pww==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '355',
  'dv88cip4jl42qaj97cw8idb0emjh',
  'Cyberpunk Future.png',
  'image/png',
  '{"fileId":"68af0c895c7cd75eb8bc3ad0","name":"Cyberpunk_Future_L5tOrhbet.png","size":1893101,"versionInfo":{"id":"68af0c895c7cd75eb8bc3ad0","name":"Version 1"},"filePath":"/Cyberpunk_Future_L5tOrhbet.png","url":"https://ik.imagekit.io/nvqgwnjgv/Cyberpunk_Future_L5tOrhbet.png","fileType":"image","height":1024,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Cyberpunk_Future_L5tOrhbet.png","AITags":null,"description":null}',
  'imagekitio',
  1893101,
  'lyPBMqFdu1geo/nJfTqT3Q==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '357',
  'ks6iv3l1x3vh7o26tbpdtabsdi4b',
  'The Jammers.png',
  'image/png',
  '{"fileId":"68af0e285c7cd75eb8c8a971","name":"The_Jammers_fqyIvpJ53.png","size":2292396,"versionInfo":{"id":"68af0e285c7cd75eb8c8a971","name":"Version 1"},"filePath":"/The_Jammers_fqyIvpJ53.png","url":"https://ik.imagekit.io/nvqgwnjgv/The_Jammers_fqyIvpJ53.png","fileType":"image","height":1024,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/The_Jammers_fqyIvpJ53.png","AITags":null,"description":null}',
  'imagekitio',
  2292396,
  'VBNMw3Mo/XUcUSKOctYwHg==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '358',
  '25xy1un2sot5ml46l8m45lijti7m',
  'The New Simian Army.png',
  'image/png',
  '{"fileId":"68af0e445c7cd75eb8c9631c","name":"The_New_Simian_Army_v4lQcL3mI.png","size":2127776,"versionInfo":{"id":"68af0e445c7cd75eb8c9631c","name":"Version 1"},"filePath":"/The_New_Simian_Army_v4lQcL3mI.png","url":"https://ik.imagekit.io/nvqgwnjgv/The_New_Simian_Army_v4lQcL3mI.png","fileType":"image","height":1024,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/The_New_Simian_Army_v4lQcL3mI.png","AITags":null,"description":null}',
  'imagekitio',
  2127776,
  'Ger9jV7A6yqBVLq0nDEhWQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '362',
  'a2q6bru3bo4qtm8gk6h9qmcg10t3',
  'The Jammers.png',
  'image/png',
  '{"fileId":"68af0f1f5c7cd75eb8d0084a","name":"The_Jammers_k-5iq_chse.png","size":2292396,"versionInfo":{"id":"68af0f1f5c7cd75eb8d0084a","name":"Version 1"},"filePath":"/The_Jammers_k-5iq_chse.png","url":"https://ik.imagekit.io/nvqgwnjgv/The_Jammers_k-5iq_chse.png","fileType":"image","height":1024,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/The_Jammers_k-5iq_chse.png","AITags":null,"description":null}',
  'imagekitio',
  2292396,
  'VBNMw3Mo/XUcUSKOctYwHg==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '366',
  '71oub0f2n2j3ltu0p2ujsilb8rx9',
  'Eaters of the Lotus.png',
  'image/png',
  '{"fileId":"68af105b5c7cd75eb8dae651","name":"Eaters_of_the_Lotus_NuQyPRoSS.png","size":2158787,"versionInfo":{"id":"68af105b5c7cd75eb8dae651","name":"Version 1"},"filePath":"/Eaters_of_the_Lotus_NuQyPRoSS.png","url":"https://ik.imagekit.io/nvqgwnjgv/Eaters_of_the_Lotus_NuQyPRoSS.png","fileType":"image","height":1024,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Eaters_of_the_Lotus_NuQyPRoSS.png","AITags":null,"description":null}',
  'imagekitio',
  2158787,
  'GltFaumBAAEhmPt6oSHYxA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '367',
  'n1xs2g03dlj4dad2fo00k88o0rvc',
  'The Guiding Hand.png',
  'image/png',
  '{"fileId":"68af10945c7cd75eb8dcbd4b","name":"The_Guiding_Hand_PsAEzSyKyF.png","size":2989784,"versionInfo":{"id":"68af10945c7cd75eb8dcbd4b","name":"Version 1"},"filePath":"/The_Guiding_Hand_PsAEzSyKyF.png","url":"https://ik.imagekit.io/nvqgwnjgv/The_Guiding_Hand_PsAEzSyKyF.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/The_Guiding_Hand_PsAEzSyKyF.png","AITags":null,"description":null}',
  'imagekitio',
  2989784,
  'CixOcnjtLauAGWHv49+s4A==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '372',
  '1prakdd1yb6a95unzvqa59t8diec',
  'The Ascended.png',
  'image/png',
  '{"fileId":"68af13ad5c7cd75eb8fc7096","name":"The_Ascended_Zx6uYB_koM.png","size":2682349,"versionInfo":{"id":"68af13ad5c7cd75eb8fc7096","name":"Version 1"},"filePath":"/The_Ascended_Zx6uYB_koM.png","url":"https://ik.imagekit.io/nvqgwnjgv/The_Ascended_Zx6uYB_koM.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/The_Ascended_Zx6uYB_koM.png","AITags":null,"description":null}',
  'imagekitio',
  2682349,
  'VMHmF1YgxMoshLjmCNaC1g==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '373',
  'pwduhl3emfgzgx1k70rp2wj3lzh7',
  'The Dragons.png',
  'image/png',
  '{"fileId":"68af14145c7cd75eb8ff8139","name":"The_Dragons_e8XI4PLDS.png","size":3682795,"versionInfo":{"id":"68af14145c7cd75eb8ff8139","name":"Version 1"},"filePath":"/The_Dragons_e8XI4PLDS.png","url":"https://ik.imagekit.io/nvqgwnjgv/The_Dragons_e8XI4PLDS.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/The_Dragons_e8XI4PLDS.png","AITags":null,"description":null}',
  'imagekitio',
  3682795,
  'YznVoOkiU3Potu5KESjixA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '377',
  'fv628kzs7gkpp22vzztyxlpswbfr',
  'Uber-Boss.png',
  'image/png',
  '{"fileId":"68af2dc85c7cd75eb8d663b8","name":"Uber-Boss_U8sbOJpEc.png","size":3299569,"versionInfo":{"id":"68af2dc85c7cd75eb8d663b8","name":"Version 1"},"filePath":"/Uber-Boss_U8sbOJpEc.png","url":"https://ik.imagekit.io/nvqgwnjgv/Uber-Boss_U8sbOJpEc.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Uber-Boss_U8sbOJpEc.png","AITags":null,"description":null}',
  'imagekitio',
  3299569,
  'PUvRz8bpusXf6A6yAdyakw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '378',
  'twy5qkogu7ogtefsx4j9uxzrujj4',
  'Boss.png',
  'image/png',
  '{"fileId":"68af2de05c7cd75eb8d7c8a9","name":"Boss_4DZnkBtBV.png","size":2913630,"versionInfo":{"id":"68af2de05c7cd75eb8d7c8a9","name":"Version 1"},"filePath":"/Boss_4DZnkBtBV.png","url":"https://ik.imagekit.io/nvqgwnjgv/Boss_4DZnkBtBV.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Boss_4DZnkBtBV.png","AITags":null,"description":null}',
  'imagekitio',
  2913630,
  'hG+QguKr3zetGiIi1La3kg==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '379',
  'hdfqznc6zpfd7zwghsrf4jfcerta',
  'Featured Foe.png',
  'image/png',
  '{"fileId":"68af2df35c7cd75eb8d8e184","name":"Featured_Foe_qetZaS6RG.png","size":2874987,"versionInfo":{"id":"68af2df35c7cd75eb8d8e184","name":"Version 1"},"filePath":"/Featured_Foe_qetZaS6RG.png","url":"https://ik.imagekit.io/nvqgwnjgv/Featured_Foe_qetZaS6RG.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Featured_Foe_qetZaS6RG.png","AITags":null,"description":null}',
  'imagekitio',
  2874987,
  'yvvTHqiVc0WjGh6T665q5A==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '380',
  'rdedykd9uvjaqdqgd4sibckyu3z0',
  'Mook.png',
  'image/png',
  '{"fileId":"68af2e035c7cd75eb8d9ddd4","name":"Mook_o6NQRGwDb.png","size":2076535,"versionInfo":{"id":"68af2e035c7cd75eb8d9ddd4","name":"Version 1"},"filePath":"/Mook_o6NQRGwDb.png","url":"https://ik.imagekit.io/nvqgwnjgv/Mook_o6NQRGwDb.png","fileType":"image","height":1024,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Mook_o6NQRGwDb.png","AITags":null,"description":null}',
  'imagekitio',
  2076535,
  'dS+nGq2vjjp3QnWWrG8rIQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '381',
  'w6c6kdxprt6fe39paw7qv70ig9gz',
  'Ally.png',
  'image/png',
  '{"fileId":"68af2e185c7cd75eb8db611e","name":"Ally_KjlHMU9ve.png","size":2885991,"versionInfo":{"id":"68af2e185c7cd75eb8db611e","name":"Version 1"},"filePath":"/Ally_KjlHMU9ve.png","url":"https://ik.imagekit.io/nvqgwnjgv/Ally_KjlHMU9ve.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Ally_KjlHMU9ve.png","AITags":null,"description":null}',
  'imagekitio',
  2885991,
  '5SXxFRvtVL8Sxy8zRjEIMw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '384',
  '3flwmlq8eilnlx3j9n1gngotrjq0',
  'Campaign.png',
  'image/png',
  '{"fileId":"68af37b55c7cd75eb829e4c5","name":"Campaign_VFkETIKci.png","size":3393825,"versionInfo":{"id":"68af37b55c7cd75eb829e4c5","name":"Version 1"},"filePath":"/Campaign_VFkETIKci.png","url":"https://ik.imagekit.io/nvqgwnjgv/Campaign_VFkETIKci.png","fileType":"image","height":1024,"width":1536,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Campaign_VFkETIKci.png","AITags":null,"description":null}',
  'imagekitio',
  3393825,
  'HSdzPDT5THDbxDd1odK2zw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '385',
  'srzk54dwh9e67797i0npwcf5shw3',
  'Huan Ken.png',
  'image/png',
  '{"fileId":"68af710c5c7cd75eb816c6ef","name":"Huan_Ken_oO2XgzfM4.png","size":3061418,"versionInfo":{"id":"68af710c5c7cd75eb816c6ef","name":"Version 1"},"filePath":"/Huan_Ken_oO2XgzfM4.png","url":"https://ik.imagekit.io/nvqgwnjgv/Huan_Ken_oO2XgzfM4.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Huan_Ken_oO2XgzfM4.png","AITags":null,"description":null}',
  'imagekitio',
  3061418,
  'b/ynh0f4ExhldRluWOrGzQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '386',
  '9f6sdzr807cs47ngps80pkklaw1g',
  'Li Ting.png',
  'image/png',
  '{"fileId":"68af71195c7cd75eb8172939","name":"Li_Ting_6_B2GDJVnc.png","size":2869432,"versionInfo":{"id":"68af71195c7cd75eb8172939","name":"Version 1"},"filePath":"/Li_Ting_6_B2GDJVnc.png","url":"https://ik.imagekit.io/nvqgwnjgv/Li_Ting_6_B2GDJVnc.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Li_Ting_6_B2GDJVnc.png","AITags":null,"description":null}',
  'imagekitio',
  2869432,
  '/75rkGON78LuFDRvmEbenw==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '387',
  '47xx0fdbytu45czwprf9d798i0cw',
  'Pui Ti.png',
  'image/png',
  '{"fileId":"68af71245c7cd75eb817790b","name":"Pui_Ti_1eLMqsaBq.png","size":3445969,"versionInfo":{"id":"68af71245c7cd75eb817790b","name":"Version 1"},"filePath":"/Pui_Ti_1eLMqsaBq.png","url":"https://ik.imagekit.io/nvqgwnjgv/Pui_Ti_1eLMqsaBq.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Pui_Ti_1eLMqsaBq.png","AITags":null,"description":null}',
  'imagekitio',
  3445969,
  '4a8+G6ODn8cHnYv0jMoUoA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '388',
  'b65276785b1ub456qu5n3eg8858d',
  'Ming Yi.png',
  'image/png',
  '{"fileId":"68af71325c7cd75eb817eff7","name":"Ming_Yi_jf1YDThyM.png","size":2365122,"versionInfo":{"id":"68af71325c7cd75eb817eff7","name":"Version 1"},"filePath":"/Ming_Yi_jf1YDThyM.png","url":"https://ik.imagekit.io/nvqgwnjgv/Ming_Yi_jf1YDThyM.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Ming_Yi_jf1YDThyM.png","AITags":null,"description":null}',
  'imagekitio',
  2365122,
  'TlN98XbAjaJ6tTlylyq5bQ==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_blobs (
  id, key, filename, content_type, metadata, 
  service_name, byte_size, checksum, created_at
) VALUES (
  '390',
  '4sq6kxk2slhc2ifqeuex58v11lf5',
  'Manlysaka.png',
  'image/png',
  '{"fileId":"68b05f8e5c7cd75eb81068c5","name":"Manlysaka_q3TJn-6_G.png","size":3145652,"versionInfo":{"id":"68b05f8e5c7cd75eb81068c5","name":"Version 1"},"filePath":"/Manlysaka_q3TJn-6_G.png","url":"https://ik.imagekit.io/nvqgwnjgv/Manlysaka_q3TJn-6_G.png","fileType":"image","height":1536,"width":1024,"thumbnailUrl":"https://ik.imagekit.io/nvqgwnjgv/tr:n-ik_ml_thumbnail/Manlysaka_q3TJn-6_G.png","AITags":null,"description":null}',
  'imagekitio',
  3145652,
  'svtuyVKQ6feOFt6TF7SSSA==',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '304',
  'image',
  'Character',
  '115f61d2-3839-42fc-9f85-d9765c7bf1f7',
  '304',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '305',
  'image',
  'Character',
  '5c62b67e-21bb-45f7-939a-c10547fa7015',
  '305',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '306',
  'image',
  'Character',
  '5ef803e9-4696-4df7-b12e-4766176d82b3',
  '306',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '307',
  'image',
  'Character',
  'd39997e5-f720-49d5-a43b-83a2d983e037',
  '307',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '308',
  'image',
  'Character',
  'ac248717-2f82-44b5-ac39-83b582777a96',
  '308',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '309',
  'image',
  'Character',
  '322d42d3-26a5-46d0-8eb8-977da4ce996c',
  '309',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '310',
  'image',
  'Character',
  '85a65881-99b7-4aba-91d9-7e759b8c761e',
  '310',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '311',
  'image',
  'Character',
  '8d1afe00-b16f-4698-95f3-64fc2e997f9e',
  '311',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '312',
  'image',
  'Character',
  'f64b9dc7-e53c-4fdd-8eeb-6480451df853',
  '312',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '313',
  'image',
  'Character',
  '23bde1d7-2561-4418-bd1b-47920351338d',
  '313',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '314',
  'image',
  'Character',
  'f7d9c375-eee7-47ec-8975-90aefe08000a',
  '314',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '317',
  'image',
  'Character',
  '317a298c-a051-46f2-9eb4-1833503fbcf6',
  '317',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '318',
  'image',
  'Character',
  '5c1abd1d-aa9a-449c-87ac-c06b7795d94e',
  '318',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '319',
  'image',
  'Character',
  '8b42e03c-2609-4ab1-85ec-47075a0b19c7',
  '319',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '320',
  'image',
  'Character',
  '3c01197d-52a0-4b2e-8f5d-377186b36537',
  '320',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '321',
  'image',
  'Character',
  'cfde27ab-7dfd-4f38-98ee-2eccc631be14',
  '321',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '322',
  'image',
  'Character',
  'dd07a0f2-0148-4c14-ab0f-f383557214ee',
  '322',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '323',
  'image',
  'Character',
  'cb78b93b-fea2-4f30-ad1f-9b69761a5da5',
  '323',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '324',
  'image',
  'Character',
  'd02c57aa-9e16-4aa7-9217-c161cea860d0',
  '324',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '325',
  'image',
  'Character',
  '46001c17-943e-47ed-bfed-40be516d6c3c',
  '325',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '326',
  'image',
  'Character',
  'fbb2e188-9d06-4987-ba1b-a489280cce5e',
  '326',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '327',
  'image',
  'Character',
  '8cef368d-9101-4b92-89c1-dc5c7965d333',
  '327',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '328',
  'image',
  'Character',
  '8e9477c6-b93a-499e-876c-ebf14427d6a8',
  '328',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '329',
  'image',
  'Character',
  'd9ad1bc8-db91-43ba-8371-fe883ab72aa3',
  '329',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '330',
  'image',
  'Character',
  'bcf03792-c296-48d8-baa8-d96261089571',
  '330',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '331',
  'image',
  'Character',
  'df233719-e808-4146-aa94-c76efa1d9db4',
  '331',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '332',
  'image',
  'Character',
  '4c5cae19-e0fc-423c-8133-513e8416d423',
  '332',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '333',
  'image',
  'Character',
  'bf96d7dd-e1df-4532-813c-255d943cea91',
  '333',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '334',
  'image',
  'Character',
  'e95d3487-5ef2-478c-8035-b878c455e463',
  '334',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '335',
  'image',
  'Character',
  'bbc04a45-4523-400b-ac21-89754a0e7440',
  '335',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '336',
  'image',
  'Character',
  '670f4efe-30d5-4d40-8a98-3b10e0b937e6',
  '336',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '337',
  'image',
  'Character',
  '92783b56-c474-412d-95ca-9b23ee3f0b97',
  '337',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '338',
  'image',
  'Character',
  '2c2efc13-84ce-45d5-9549-b5b058b2ebe0',
  '338',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '339',
  'image',
  'Character',
  'b1103cf5-a767-4ee3-aa18-4d914ec74f28',
  '339',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '340',
  'image',
  'Character',
  'bd661084-c670-4910-b568-3a2962a621e5',
  '340',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '346',
  'image',
  'Juncture',
  '2c6289f5-e827-4ebb-a545-a83966e3c6ea',
  '346',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '348',
  'image',
  'Juncture',
  '2e6a9b7a-2ca6-4a6f-968a-9654ac58d1e7',
  '348',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '349',
  'image',
  'Juncture',
  '4d64ba1d-879e-4de3-ba61-f85eb25cc2b4',
  '349',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '350',
  'image',
  'Juncture',
  '49729394-c8fd-438e-ba06-a801092c0594',
  '350',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '352',
  'image',
  'Faction',
  'd12ebf38-6bf4-485d-ab01-36e71e99306a',
  '352',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '353',
  'image',
  'Juncture',
  '044041d8-94b9-4551-9c01-5adff074c5a5',
  '353',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '355',
  'image',
  'Juncture',
  'ffc77a44-da5c-4dc8-83a4-469cf1699ba2',
  '355',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '357',
  'image',
  'Juncture',
  '0ae9913e-02f6-4fae-9453-150d3167091e',
  '357',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '358',
  'image',
  'Faction',
  '9afef0d9-233c-4696-b237-aed0515e0500',
  '358',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '362',
  'image',
  'Faction',
  '50a7bc5c-ca36-48b7-a17b-5698c2e1958e',
  '362',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '366',
  'image',
  'Faction',
  '8a2a13dc-447f-4e71-98fd-732c8d65be78',
  '366',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '367',
  'image',
  'Faction',
  'c52de513-622e-4bda-a88e-cec2a5c13ddb',
  '367',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '372',
  'image',
  'Faction',
  'f9c89687-9813-4c50-98fb-ceecfcc5e335',
  '372',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '373',
  'image',
  'Faction',
  '6bc3abe7-2890-432f-a397-89c763f54d18',
  '373',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '377',
  'image',
  'Character',
  'aaf89162-4329-4924-9141-dd8ba02c13a8',
  '377',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '378',
  'image',
  'Character',
  '7a367c9d-ad7f-4bc8-9050-30a58a9e4e99',
  '378',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '379',
  'image',
  'Character',
  '3947d2d8-163a-4bdd-83e8-0de8f751e861',
  '379',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '380',
  'image',
  'Character',
  '67f709a8-521f-48b5-a3d6-cee40868236a',
  '380',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '381',
  'image',
  'Character',
  'f0310e8e-871f-46c5-8497-f9e484824281',
  '381',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '384',
  'image',
  'Campaign',
  '7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2',
  '384',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '385',
  'image',
  'Faction',
  'c2c5b7cc-0c64-4866-97c1-b1c9b0e8c457',
  '385',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '386',
  'image',
  'Faction',
  'f1b59811-a684-4d3f-a07b-4fcafc79eb7d',
  '386',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '387',
  'image',
  'Faction',
  'ce40d0a1-ed7c-4122-a219-996e46425115',
  '387',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '388',
  'image',
  'Faction',
  '954edb9f-afd2-4df8-985d-6756594d0d94',
  '388',
  NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO active_storage_attachments (
  id, name, record_type, record_id, blob_id,
  created_at
) VALUES (
  '390',
  'image',
  'Faction',
  'c44f7eaf-425b-497f-b278-92a3bc612e55',
  '390',
  NOW()
) ON CONFLICT (id) DO NOTHING;

COMMIT;
