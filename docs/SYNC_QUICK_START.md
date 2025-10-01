# Campaign Template Sync - Quick Start

## TL;DR

```bash
# 1. List campaigns and find your ID
rails campaign:list

# 2. Preview changes (DRY RUN - safe, no changes made)
rails campaign:sync_template[your-campaign-id]

# 3. Apply changes (LIVE - actually makes changes)
DRY_RUN=false rails campaign:sync_template[your-campaign-id]
```

## What Gets Updated

- ✅ **Schticks**: All attributes + images (matched by name, preserves ID)
- ✅ **Weapons**: All attributes + images (matched by name, preserves ID)
- ✅ **Template Characters**: Copied as new records (only if `is_template: true`)

## Safety

- Dry-run by default (must explicitly set `DRY_RUN=false`)
- Transaction-wrapped (rolls back on error)
- Preserves record IDs for schticks/weapons
- Skips characters that already exist (no overwrites)

## Example Session

```bash
# Check which campaign is the master template
$ rails campaign:list
# Output shows: 7b17864e-4e39-41c2-a5b7-6bbbd5aa4ff2 | Master Campaign [MASTER TEMPLATE]

# Find your long-running campaign
# Output shows: 0f2b51c0-80c0-4f5f-b55f-76186903df3e | Born to Revengeance

# Preview what will change
$ rails campaign:sync_template[0f2b51c0-80c0-4f5f-b55f-76186903df3e]

# Review the output, then apply if satisfied
$ DRY_RUN=false rails campaign:sync_template[0f2b51c0-80c0-4f5f-b55f-76186903df3e]
```

## Zsh Users

If you use zsh, escape the brackets:

```bash
rails campaign:sync_template\[your-campaign-id\]
```

Or use quotes:

```bash
rails "campaign:sync_template[your-campaign-id]"
```

## See TEMPLATE_SYNC_GUIDE.md for complete documentation
