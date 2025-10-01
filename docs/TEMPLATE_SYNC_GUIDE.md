# Campaign Template Sync Guide

This guide explains how to update an existing campaign with template content (schticks, weapons, and template characters) from the master template campaign.

## What This Does

The `CampaignTemplateSyncService` updates an existing campaign with:

1. **Schticks**: Matches by name and updates all attributes and images
2. **Weapons**: Matches by name and updates all attributes and images
3. **Template Characters**: Copies all characters with `is_template: true` from source campaign

**Important**: This overwrites existing schtick/weapon data but preserves the record IDs. Characters are copied as new records (not overwriting).

## Prerequisites

- Identify your target campaign ID
- Ensure master template campaign exists (or specify custom source)
- Backup your database before running in LIVE mode

## Usage

### 1. List Available Campaigns

```bash
cd shot-server
rails campaign:list
```

This shows all campaigns with their IDs and indicates which is the master template.

### 2. Dry Run (Preview Changes)

**Always run dry-run first to preview changes:**

```bash
rails campaign:sync_template[your-campaign-id]
# or explicitly:
DRY_RUN=true rails campaign:sync_template[your-campaign-id]
```

This will show:
- Which schticks will be updated and what will change
- Which weapons will be updated and what will change
- Which template characters will be copied
- What will be skipped and why

### 3. Apply Changes (Live Mode)

After reviewing the dry run output:

```bash
DRY_RUN=false rails campaign:sync_template[your-campaign-id]
```

**Note**: Zsh users may need to escape brackets:
```bash
DRY_RUN=false rails campaign:sync_template\[your-campaign-id\]
```

### 4. Custom Source Campaign

To sync from a campaign other than the master template:

```bash
SOURCE_CAMPAIGN_ID=source-id DRY_RUN=true rails campaign:sync_template[target-id]
```

## Rails Console Usage

You can also run the service directly in Rails console:

```ruby
# Dry run
service = CampaignTemplateSyncService.new('campaign-id', dry_run: true)
service.sync!

# Live run
service = CampaignTemplateSyncService.new('campaign-id', dry_run: false)
service.sync!

# Custom source campaign
service = CampaignTemplateSyncService.new(
  'target-id',
  source_campaign_id: 'source-id',
  dry_run: true
)
service.sync!
```

## Understanding the Output

### Dry Run Output Example

```
================================================================================
Campaign Template Sync
Source: Master Campaign Template (ID: abc-123)
Target: My Long-Running Campaign (ID: xyz-789)
Mode: DRY RUN
================================================================================

--- Syncing Schticks ---
Found 150 schticks in source campaign

  UPDATE: Aikido (ID: schtick-id-123)
    - image: none -> aikido.png (45678 bytes)
    - description:
        FROM: Old description
        TO:   Updated description with more detail

  SKIP: Archery (already up to date)

--- Syncing Weapons ---
Found 75 weapons in source campaign

  UPDATE: .44 Magnum (ID: weapon-id-456)
    - image: none -> magnum.png (23456 bytes)
    - damage:
        FROM: 13
        TO:   14

--- Syncing Template Characters ---
Found 50 template characters in source campaign

  COPY: Agent Smith (Featured Foe - Secret Agent)
  COPY: Dragon Guardian (Boss - Supernatural Creature)
  SKIP: Generic Mook (already exists)

================================================================================
SYNC SUMMARY
================================================================================

Schticks:
  - Updated: 87
  - Skipped: 63

Weapons:
  - Updated: 42
  - Skipped: 33

Template Characters:
  - Copied: 48
  - Skipped: 2

================================================================================

This was a DRY RUN - no changes were made.
To apply these changes, run with dry_run: false

================================================================================
```

## Matching Logic

### Schticks & Weapons
- Matches by **exact name** (case-sensitive)
- If found: updates all attributes and replaces image
- If not found: skips (not created)

### Template Characters
- Matches by **exact name** (case-sensitive)
- If found: skips (doesn't overwrite)
- If not found: copies as new character with all associations

## Safety Features

- **Dry-run mode by default**: Must explicitly set `DRY_RUN=false` to apply changes
- **Transaction wrapper**: All changes rolled back on error
- **Detailed logging**: Every change is logged
- **Error tracking**: Errors captured and reported in summary
- **ID preservation**: Schticks and weapons keep their original IDs

## Common Use Cases

### Update Old Campaign with Latest Content

```bash
# 1. Preview
rails campaign:sync_template[old-campaign-id]

# 2. Apply
DRY_RUN=false rails campaign:sync_template[old-campaign-id]
```

### Copy Template Characters to New Campaign

```bash
# If you only want template characters, this will skip schticks/weapons that match
rails campaign:sync_template[new-campaign-id]
```

### Sync Between Two Custom Campaigns

```bash
SOURCE_CAMPAIGN_ID=source-id rails campaign:sync_template[target-id]
```

## Troubleshooting

### "No source campaign found"
- Ensure master template campaign exists with `is_master_template: true`
- Or specify `SOURCE_CAMPAIGN_ID` explicitly

### "Target campaign not found"
- Verify campaign ID is correct using `rails campaign:list`

### Image Attachment Failures
- Check ImageKit configuration
- Verify network connectivity for image downloads
- Review Rails logs for specific error messages

### Character Copy Failures
- Check for validation errors in character model
- Verify all required associations exist in target campaign
- Review Rails logs for detailed error messages

## Extending the Service

The service can be extended to sync additional resources by:

1. Adding new sync methods (e.g., `sync_factions`, `sync_sites`)
2. Following the same pattern: match by name, calculate changes, log, update
3. Adding to the transaction in the `sync!` method

See `app/services/campaign_template_sync_service.rb` for implementation details.
