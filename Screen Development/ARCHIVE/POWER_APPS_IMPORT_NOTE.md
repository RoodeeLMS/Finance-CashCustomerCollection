# Power Apps YAML Syntax Fix

**Issue**: YAML Syntax Error - Multiline Formulas
**Date**: 2025-10-09
**Status**: ✅ FIXED - Use `|-` for all multiline formulas

---

## Error Message

```
error PA1001 : An error occurred while parsing PaYaml. Error code: YamlInvalidSyntax
Reason: While parsing a block mapping, did not find expected key.
```

---

## Root Cause

**YAML syntax error with multiline formulas**. When a formula spans multiple lines (like nested `If()` statements), you MUST use the `|-` literal block scalar indicator.

### ❌ WRONG (Causes Syntax Error):
```yaml
Properties:
  Icon: =If(
      condition,
      value1,
      value2
  )
  Color: =RGBA(255, 0, 0, 1)
```

**Problem**: The closing `)` on its own line causes YAML to misparse the structure. YAML thinks the Icon property ended at line 2, making `Color:` appear at the wrong indentation level (expected to be a child of the previous property).

### ✅ CORRECT:
```yaml
Properties:
  Icon: |-
    =If(
        condition,
        value1,
        value2
    )
  Color: =RGBA(255, 0, 0, 1)
```

**Solution**: The `|-` tells YAML "everything indented below is a literal string", preventing parsing errors.

---

## What Was Fixed

Fixed **11 multiline formulas** in `scnDailyControlCenter_v2_withDatePicker.yaml`:

### 1. Icon Properties (3 locations)
```yaml
# Line 430: SAPStatusIcon
Icon: |-
  =If(...)

# Line 522: EmailStatusIcon
Icon: |-
  =If(...)

# Line 758: ActivityIcon
Icon: |-
  =If(...)
```

### 2. Color Properties (3 locations)
```yaml
# Line 440: SAPStatusIcon
Color: |-
  =If(...)

# Line 532: EmailStatusIcon
Color: |-
  =If(...)

# Line 768: ActivityIcon
Color: |-
  =If(...)
```

### 3. Fill Properties (1 location)
```yaml
# Line 651: ViewFailedButton
Fill: |-
  =If(...)
```

### 4. DisplayMode Properties (1 location)
```yaml
# Line 660: ViewFailedButton
DisplayMode: |-
  =If(...)
```

### 5. FontColor Properties (1 location)
```yaml
# Line 823: ActivityStatus
FontColor: |-
  =If(...)
```

### 6. Text Properties (2 locations)
```yaml
# Line 493: SAPRecordCount
Text: |-
  =If(...)

# Line 585: EmailSkippedCount
Text: |-
  =If(...)
```

---

## Rule for All YAML Files

**MANDATORY**: Any property with a multiline formula MUST use `|-`

### When to Use `|-`

✅ **USE** `|-` when:
- Formula spans multiple lines
- Nested `If()` statements
- Long formulas with line breaks for readability
- Any formula where the closing `)` is on its own line

❌ **DON'T USE** `|-` when:
- Single-line formula (e.g., `Text: ="Hello"`)
- Simple property value (e.g., `Width: =100`)
- Already using `|-` for text blocks (correct)

### Examples

```yaml
# Single line - NO |-
Text: ="Customer Name"
Width: =960
Height: =40

# Single line with function - NO |-
Fill: =RGBA(0, 101, 161, 1)
OnSelect: =Navigate(scnHome)

# Multiline for readability - YES |-
OnVisible: |-
  =Set(varName, "value");
  Refresh(DataSource);
  Navigate(scnHome)

# Nested If - YES |-
Fill: |-
  =If(
      condition1,
      value1,
      If(
          condition2,
          value2,
          value3
      )
  )

# Text block - YES |- (already correct)
Text: |-
  ="Line 1" & Char(10) &
  "Line 2"
```

---

## Testing

After fixes, the YAML file should:
- ✅ Paste into Power Apps Studio without syntax errors
- ✅ All formulas evaluate correctly
- ✅ No "expected key" errors

---

## Checklist for New Screens

When creating new screen YAML files:

- [ ] Use `|-` for ALL multiline formulas
- [ ] Check nested `If()` statements
- [ ] Check `OnVisible` and `OnSelect` with multiple statements
- [ ] Check conditional `Fill`, `Color`, `DisplayMode`, `FontColor`
- [ ] Test paste into Power Apps Studio
- [ ] Run `/quick-check` before committing

---

## Reference

**YAML Literal Block Scalar Syntax**:
- `|-` : Literal block, strip final newlines
- `|` : Literal block, keep final newlines
- `>` : Folded block (joins lines with spaces)

For Power Apps formulas, always use `|-` (literal block, strip newlines).

**Docs**: https://yaml.org/spec/1.2.2/#812-literal-style

---

**Last Updated**: 2025-10-09
**Status**: ✅ FIXED - All syntax errors resolved
