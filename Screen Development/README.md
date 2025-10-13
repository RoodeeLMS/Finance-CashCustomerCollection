# Screen Development

**Purpose**: Organized workflow for Power Apps screen development following Nestlé Universal Standards.

---

## 📁 Folder Structure

```
Screen Development/
├── ACTIVE/          # ✏️ Work in progress (quick iterations)
├── READY/           # ✅ Reviewed and approved (ready for import)
└── ARCHIVE/         # 📦 Historical versions (after import)
```

---

## 🚀 Development Workflow

### Stage 1: ACTIVE Development

**Purpose**: Rapid iteration and development

**Actions**:
1. Create new screen in `ACTIVE/`
2. Use `/quick-check <file>` frequently (10-30 sec)
3. Fix errors as you go
4. Iterate until screen works

**Status**:
- Files are work-in-progress
- Can be gitignored (optional)
- No formal review required

**Move to Next Stage**: When screen is functionally complete

---

### Stage 2: READY for Production

**Purpose**: Formal review and approval

**Actions**:
1. Say "review scnScreenName" for full review (2-3 min)
2. Fix ALL critical errors (must fix)
3. Fix ALL standards issues (should fix)
4. Consider best practices (nice to have)
5. Move file to `READY/`

**Quality Gates**:
- ✅ Zero critical errors
- ✅ Nestlé brand compliant
- ✅ Universal standards compliant
- ✅ Field names verified from FIELD_NAME_REFERENCE.md

**Move to Next Stage**: After successful Power Apps Studio import and export

---

### Stage 3: ARCHIVE Historical

**Purpose**: Clean up and preserve history

**Actions**:
1. Import screen to Power Apps Studio manually
2. Test in Power Apps Studio
3. Export from Power Apps Studio to `Powerapp screens-DO-NOT-EDIT/`
4. Move working file from `READY/` to `ARCHIVE/` (optional)

**Status**:
- Production version lives in `Powerapp screens-DO-NOT-EDIT/`
- Working file preserved in `ARCHIVE/` for reference
- `READY/` folder stays clean

---

## 🎯 Current Status

### Ready for Import (1)
- ✅ **scnDailyControlCenter.yaml** - Daily Control Center landing page

### In Development (0)
- None

### Archived (0)
- None

---

## 📖 Documentation References

### For Screen Development
1. **`SCREEN_DEVELOPMENT_GUIDE.md`** ⭐ - Complete workflow & patterns
2. **`FIELD_NAME_REFERENCE.md`** - Field names (cr7bb_ prefix)
3. **`REDESIGNED_SCREENS.md`** - Screen architecture decisions

### Universal Standards
**Location**: `~/.claude/powerapp-standards/`
- `universal-powerapp-checklist.md` - Critical rules
- `nestle-brand-standards.md` - Colors, fonts
- `dataverse-common-patterns.md` - Dataverse syntax

---

## ⚙️ Available Tools

### Subagent (Auto)
- **`powerapp-screen-reviewer`** - Comprehensive review (2-3 min)
  - Auto-activates when you say "review scnScreenName"
  - Checks critical errors, standards, best practices

### Slash Commands (Manual)
- **`/quick-check <file>`** - Fast syntax check (10-30 sec, critical only)
- **`/review-powerapp-screen <file>`** - Same as subagent, manual trigger

---

## 📋 Quick Commands

### Development Phase
```bash
# Create new screen
touch "Screen Development/ACTIVE/scnNewScreen.yaml"

# Quick check during development (fast)
/quick-check "Screen Development/ACTIVE/scnNewScreen.yaml"

# Full review when ready (thorough)
/review-powerapp-screen "Screen Development/ACTIVE/scnNewScreen.yaml"
# Or just say: "review scnNewScreen"
```

### Approval Phase
```bash
# Move to READY after passing review
mv "Screen Development/ACTIVE/scnNewScreen.yaml" "Screen Development/READY/"
```

### Production Phase
```bash
# After Power Apps Studio export, archive working file
mv "Screen Development/READY/scnNewScreen.yaml" "Screen Development/ARCHIVE/scnNewScreen_v1.yaml"
```

---

## ✅ Pre-Move Checklist

### Before moving ACTIVE → READY:
- [ ] Full review completed (no critical errors)
- [ ] All standards issues fixed
- [ ] Nestlé brand colors used (0, 101, 161)
- [ ] Field names verified from FIELD_NAME_REFERENCE.md
- [ ] LayoutMinHeight/LayoutMinWidth on all containers
- [ ] Text controls have Width property
- [ ] Correct control versions (Icon@2.5.0, Gallery@2.15.0)

### Before moving READY → ARCHIVE:
- [ ] Screen imported to Power Apps Studio
- [ ] Tested in Power Apps Studio (works correctly)
- [ ] Exported from Power Apps Studio to `Powerapp screens-DO-NOT-EDIT/`
- [ ] Production version is working

---

## 🎓 Best Practices

### ACTIVE Folder
- ✅ Experiment freely
- ✅ Use quick-check frequently
- ✅ Commit work-in-progress (optional)
- ❌ Don't import to Power Apps Studio without review

### READY Folder
- ✅ All files are production-ready
- ✅ Commit to git for tracking
- ✅ Safe to share with team
- ❌ Don't skip the review process

### ARCHIVE Folder
- ✅ Keep for reference and learning
- ✅ Organize by version or date
- ✅ Can gitignore to reduce size
- ❌ Don't use as primary backup (use git)

---

## 🔄 Git Integration

### Recommended .gitignore
```
# Active development (optional, keep for work-in-progress tracking)
# Screen Development/ACTIVE/

# Archive (optional, reduce repository size)
Screen Development/ARCHIVE/

# Always ignore - production exports
Powerapp screens-DO-NOT-EDIT/
Powerapp components-DO-NOT-EDIT/
```

### What to Commit
- ✅ `Screen Development/READY/*.yaml` - Approved screens
- ✅ `Screen Development/README.md` - This file
- ✅ `Screen Development/*/README.md` - Folder guides
- ❌ `Powerapp screens-DO-NOT-EDIT/` - Power Apps exports (read-only)

---

## 📊 Success Metrics

Track screen development quality:

- **First-time pass rate**: Target >70%
- **Critical errors per screen**: Target <3
- **Time in ACTIVE**: Target <2 days per screen
- **Time in READY**: Target <1 day (quick import)

---

## 🆘 Common Issues

### "My screen has errors in Power Apps Studio"
→ Run `/quick-check` first, then full review if needed

### "I can't find my screen"
→ Check all three folders: ACTIVE, READY, ARCHIVE

### "Screen passed review but fails in Power Apps Studio"
→ Field names might be wrong. Verify from `Powerapp screens-DO-NOT-EDIT/` exports

### "Should I commit ACTIVE files?"
→ Optional. Commit for work-in-progress tracking, or gitignore for clean history

---

**Last Updated**: 2025-10-09
**Total Screens**: 1 (1 READY, 0 ACTIVE, 0 ARCHIVED)
**Next Screen**: Email Monitor (planned)
