# Screen Development - ACTIVE Folder

**Purpose**: Work-in-progress screens and screen description files ready for implementation

**Last Updated**: 2025-01-10

---

## 📋 Screen Description Files (Ready for Creator Subagent)

| Screen | Description File | Status | Template | Priority |
|--------|------------------|--------|----------|----------|
| **loadingScreen** | `loadingScreen-description.md` | ✅ Ready | Custom | **HIGH** |
| **scnDashboard** | `scnDashboard_CREATION_BRIEF.md` | ✅ Ready | template-basic-screen.yaml | **HIGH** |
| **scnUnauthorized** | `scnUnauthorized-description.md` | ✅ Ready | Custom | **HIGH** |
| **scnCustomer** | `scnCustomer-description.md` | ✅ Ready | template-basic-screen.yaml | MEDIUM |
| **scnTransactions** | `scnTransactions-description.md` | ✅ Ready | template-basic-screen.yaml | MEDIUM |
| **scnSettings** | `scnSettings-description.md` | ✅ Ready | template-basic-screen.yaml | LOW |
| **scnRole** | `scnRole-description.md` | ✅ Ready | template-table-view.yaml | LOW |

---

## 🔄 Usage Workflow

### For Main Agent (Claude Code)

**When user requests screen creation:**

1. **Check if description file exists** in this folder
2. **If YES**:
   - Ask user to review the description file
   - Get user approval
   - Invoke powerapp-screen-creator subagent with:
     ```
     "Read and implement: Screen Development/ACTIVE/[screenName]-description.md"
     ```
3. **If NO**:
   - Read template: `~/.claude/powerapp-standards/screen-templates/screen-description-template.md`
   - Read comprehensive design: `Documentation/COMPREHENSIVE_APP_DESIGN.md`
   - Gather requirements from user
   - Create description file in this folder
   - Go to step 2

### For Users (Manual Testing)

1. **Review** description file mockup and specifications
2. **Approve** for implementation
3. After subagent creates YAML file:
   - Use `/quick-check [screenName].yaml` for fast validation (10-30 sec)
   - OR say "review [screenName]" for comprehensive review (2-3 min)
4. **Fix** any critical errors found
5. **Copy** YAML content and paste into Power Apps Studio
6. **Test** in Power Apps Studio
7. If approved, **move** to `Screen Development/READY/` folder

---

## 📊 Development Priority

### Phase 1: Core Screens (HIGH Priority) ✅ COMPLETE
1. ✅ **loadingScreen** - Entry point (READY)
2. ✅ **scnDashboard** - Main operational screen (READY)
3. ✅ **scnUnauthorized** - Access denied (READY)

### Phase 2: Operational Screens (MEDIUM Priority) ✅ COMPLETE
4. ✅ **scnCustomer** - Customer management (READY)
5. ✅ **scnTransactions** - Transaction review (READY)

### Phase 3: Admin Screens (LOW Priority) ✅ COMPLETE
6. ✅ **scnSettings** - Configuration (READY)
7. ✅ **scnRole** - User management (READY)

---

## 🎉 ALL SCREEN DESCRIPTIONS COMPLETE! (7 of 7)

All screen description files have been created and are ready for the powerapp-screen-creator subagent.

---

## 📝 Quick Commands

**Check screen syntax**:
```
/quick-check Screen Development/ACTIVE/[screenName].yaml
```

**Full screen review**:
```
review [screenName]
```

**Create description file** (for remaining 4 screens):
- Read: `~/.claude/powerapp-standards/screen-templates/screen-description-template.md`
- Read: `Documentation/COMPREHENSIVE_APP_DESIGN.md`
- Write: `Screen Development/ACTIVE/[screenName]-description.md`

---

## Git Status

**Folder Status**: Optional `.gitignore`
- Description files: **COMMIT** (persistent documentation)
- YAML files: **GITIGNORE** (work-in-progress, paste into Power Apps Studio)

---

**Last Updated**: 2025-01-10
**Created By**: Claude Code Assistant
**Project**: Finance Cash Customer Collection - Nestlé Thailand
