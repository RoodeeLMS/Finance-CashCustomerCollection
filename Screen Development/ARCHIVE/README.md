# ARCHIVE - Historical Versions

**Purpose**: Store old versions of screens after they've been imported to Power Apps Studio.

## Usage

This folder contains:
- 📦 **Historical versions** of screens
- 🗂️ **Backup copies** before major changes
- 📝 **Reference implementations** for learning

## Why Archive?

After a screen is imported to Power Apps Studio and exported to `Powerapp screens-DO-NOT-EDIT/`:
- The working file in `READY/` is no longer needed
- Moving to `ARCHIVE/` keeps `READY/` clean
- Preserves history for reference

## Workflow

```bash
# After successful import and Power Apps Studio export:
mv "Screen Development/READY/scnMyScreen.yaml" "Screen Development/ARCHIVE/scnMyScreen_v1.yaml"

# Or organize by date:
mv "Screen Development/READY/scnMyScreen.yaml" "Screen Development/ARCHIVE/scnMyScreen_2025-10-09.yaml"
```

## Naming Convention

- **Version-based**: `scnMyScreen_v1.yaml`, `scnMyScreen_v2.yaml`
- **Date-based**: `scnMyScreen_2025-10-09.yaml`
- **Feature-based**: `scnMyScreen_beforeRefactor.yaml`

## Git Status

**Folder Status**: `.gitignore` (recommended)
- Archive files are historical
- Not needed for production
- Can be gitignored to reduce repository size
- Keep local for reference

## When to Archive

✅ Archive when:
- Screen successfully imported to Power Apps Studio
- Power Apps Studio export completed to `Powerapp screens-DO-NOT-EDIT/`
- Screen is working in production
- You want to start major refactoring

❌ Don't archive:
- Screens still in development
- Screens not yet tested in Power Apps Studio
- Only copy you have

## Retrieval

If you need to reference an old version:

```bash
# View archived versions
ls "Screen Development/ARCHIVE/"

# Copy back to ACTIVE for modifications
cp "Screen Development/ARCHIVE/scnMyScreen_v1.yaml" "Screen Development/ACTIVE/scnMyScreen.yaml"

# Compare versions
diff "Screen Development/ARCHIVE/scnMyScreen_v1.yaml" "Powerapp screens-DO-NOT-EDIT/scnMyScreen.yaml"
```

---

**Last Updated**: 2025-10-09
**Files Archived**: 0
