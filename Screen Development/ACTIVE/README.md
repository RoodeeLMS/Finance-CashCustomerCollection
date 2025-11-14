# Screen Development/ACTIVE

**This is the active development workspace for Canvas App screens.**

---

## 📁 Directory Structure

```
ACTIVE/
├── loadingScreen.yaml                    # Loading screen (production)
├── scnDashboard.yaml                     # Dashboard screen (production)
├── scnEmailApproval.yaml                 # Email approval (production)
├── scnEmailMonitor.yaml                  # Email monitor (production)
├── scnTransactions.yaml                  # Transactions screen (production)
├── scnCustomerHistory.yaml               # Customer history (production)
├── descriptions/                         # Screen requirement specifications
│   ├── scnCustomer-description.md
│   ├── scnCustomerHistory-description.md
│   ├── scnDashboard-description.md
│   ├── scnEmailApproval-description.md
│   ├── scnEmailMonitor-description.md
│   ├── scnRole-description.md
│   ├── scnSettings-description.md
│   ├── scnTransactions-description.md
│   └── scnUnauthorized-description.md
└── CLEANUP_STATE_V1_0_0_5.md             # Cleanup documentation
```

---

## 🔄 Development Workflow

### 1. Start with Requirements
- Read or create `descriptions/scnMyScreen-description.md`
- Defines all controls, formulas, and behavior
- Used by screen creator subagent

### 2. Create/Edit Screen
- Work in `ACTIVE/scnMyScreen.yaml`
- Use description as specification
- Follow Nestlé Power Apps standards

### 3. Validate During Development
```bash
/quick-check "Screen Development/ACTIVE/scnMyScreen.yaml"
```
Quick syntax check (10-30 sec, critical errors only)

### 4. Full Review When Ready
```bash
/review-powerapp-screen "Screen Development/ACTIVE/scnMyScreen.yaml"
```
Comprehensive check (2-3 min, all standards)

### 5. Export to Production
- Open Power Apps Studio
- Export screen → `Powerapp screens-DO-NOT-EDIT/scnMyScreen.yaml`
- This becomes the official source

### 6. Commit Changes
- Commit description files to git
- Commit approved exports to `Powerapp screens-DO-NOT-EDIT/`
- Working files in ACTIVE are temporary

---

## ✅ Current Production Screens

All screens in this directory match `Powerapp screens-DO-NOT-EDIT/` (production versions):

| Screen | Status | Purpose |
|--------|--------|---------|
| `loadingScreen.yaml` | ✅ Production | Initial loading experience |
| `scnDashboard.yaml` | ✅ Production | AR Control Center dashboard |
| `scnCustomerHistory.yaml` | ✅ Production | Transaction history viewer |
| `scnEmailApproval.yaml` | ✅ Production | Email approval workflow |
| `scnEmailMonitor.yaml` | ✅ Production | Email log monitoring |
| `scnTransactions.yaml` | ✅ Production | Transaction list & details |

---

## 📝 Description Files

Each screen has a description file in `descriptions/` that documents:
- **Purpose** - What the screen does
- **Data Source** - Which Dataverse tables/SharePoint lists
- **Controls** - List of all UI controls with properties
- **Formulas** - Key PowerFx expressions
- **Navigation** - How user navigates to/from screen
- **Styling** - Colors, fonts, layout rules
- **Behavior** - User interactions and business logic

**Why Keep Both?**
- YAML file: Actual implementation
- Description file: Requirements & documentation
- Both are git-tracked for version history

---

## 🚀 Quick Start for New Development

### Option 1: Create from Template
```
1. Create description file from template
2. Get user approval
3. Use /create-screen command to generate implementation
4. Review and export
```

### Option 2: Edit Existing Screen
```
1. Find relevant YAML file
2. Update in ACTIVE/
3. Run /quick-check for validation
4. Export from Power Apps Studio
```

---

## ⚠️ Important Rules

- ✅ **DO**: Work in ACTIVE for development
- ✅ **DO**: Update description files for changes
- ✅ **DO**: Export to `Powerapp screens-DO-NOT-EDIT/` when complete
- ✅ **DO**: Use `/quick-check` during development
- ✅ **DO**: Commit description files to git

- ❌ **DON'T**: Commit unfinished YAML from ACTIVE
- ❌ **DON'T**: Ignore validation warnings
- ❌ **DON'T**: Skip the description file requirement
- ❌ **DON'T**: Manually edit `Powerapp screens-DO-NOT-EDIT/` (export only)

---

## 📚 Resources

- **Nestlé Standards**: `~/.claude/powerapp-standards/`
- **Project Rules**: `CLAUDE.md` (root)
- **Solution Guide**: `Powerapp solution Export/IMPORT_INSTRUCTIONS.md`
- **Database Schema**: `Documentation/02-Database-Schema/FIELD_NAME_REFERENCE.md`
- **Cleanup Notes**: `CLEANUP_STATE_V1_0_0_5.md`

---

## 🎯 Current Status

**State**: v1.0.0.5 - Production Ready
**Last Updated**: November 14, 2025
**Solution Version**: Ready for import and deployment

✅ All screens production-ready
✅ All descriptions current
✅ Development workflow optimized
✅ Ready for next development cycle
