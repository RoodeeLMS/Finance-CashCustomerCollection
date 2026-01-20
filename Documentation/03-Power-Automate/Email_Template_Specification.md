# Email Template Specification

**Document**: Customer Collection Email Templates
**Version**: 1.1
**Last Updated**: 2026-01-18
**Status**: Approved by Client (Updated with regional contacts)

---

## Overview

This document defines the email templates used by the Daily Collections Email Engine to send payment reminders to cash customers. There are 4 template types based on arrear days and MI document status.

---

## Template Selection Logic

```
┌─────────────────────────────────────────────────────────┐
│                    START                                │
│                      │                                  │
│                      ▼                                  │
│            Has MI Document?                             │
│           (DocType = "MI")                              │
│                 /    \                                  │
│               Yes     No                                │
│                │       │                                │
│                ▼       ▼                                │
│          Template D   MaxArrearDays ≥ 4?                │
│                            /    \                       │
│                          Yes     No                     │
│                           │       │                     │
│                           ▼       ▼                     │
│                     Template C   MaxArrearDays = 3?     │
│                                      /    \             │
│                                    Yes     No           │
│                                     │       │           │
│                                     ▼       ▼           │
│                               Template B   Template A   │
└─────────────────────────────────────────────────────────┘
```

### Selection Rules

| Template | Condition | Description |
|----------|-----------|-------------|
| **A** | MaxArrearDays ≤ 2 | Standard reminder (Day 1-2) |
| **B** | MaxArrearDays = 3 | MI warning - pay today to avoid MI |
| **C** | MaxArrearDays ≥ 4 | MI coming soon warning |
| **D** | Has MI Document | MI explanation (MI already posted) |

**Priority**: Template D > C > B > A (check in this order)

---

## Standard Template Structure (ALL Templates)

All templates share the same structure. Only the **Warning Text** section varies.

```
┌────────────────────────────────────────────────────────────────────┐
│ Subject Line                                                       │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│ Greeting                                                           │
│                                                                    │
│ Body Introduction                                                  │
│                                                                    │
│ [WARNING TEXT - Template B/C/D only, RED color]                    │
│                                                                    │
│ ┌─────────────────────────────────────────────────────────────────┐│
│ │                    TRANSACTION TABLE                            ││
│ │ Account │ Name │ Doc No │ Assignment │ Type │ Date │ Amount    ││
│ │─────────┴──────┴────────┴────────────┴──────┴──────┴───────────││
│ │ ... transaction rows ...                                        ││
│ │─────────────────────────────────────────────────────────────────││
│ │ [CustomerCode] [CustomerName]                    │ [TOTAL]      ││
│ └─────────────────────────────────────────────────────────────────┘│
│                                                                    │
│ ┌─────────────────┬─────────────────────────────────────────────┐  │
│ │   Promptpay     │               Bill payment                  │  │
│ │   [QR CODE]     │   Bill payment instructions                 │  │
│ │   [CustCode]    │   Ref # 1: XXXXXX                          │  │
│ │                 │   Ref # 2: 999AXXXXXXX                     │  │
│ └─────────────────┴─────────────────────────────────────────────┘  │
│   (QR section hidden if QR not available)                          │
│                                                                    │
│ Footer Notes (หมายเหตุ)                                             │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## Static Text Elements

### Subject Line Format

```
[CustomerCode] [CustomerName] รายละเอียดบิลวันที่ [ProcessDate]
```

**Example**: `5411544 Chuenchomtaveerat Co.,Ltd. รายละเอียดบิลวันที่ 17.09.2025`

---

### Greeting (ALL Templates)

```
เรียนเจ้าของกิจการ
```

---

### Body Introduction (ALL Templates)

```
ท่านสามารถชำระเงินได้ตามรายละเอียดข้างท้ายนี้
```

---

### Bill Payment Section (ALL Templates)

```
Bill payment

รบกวนเติมข้อมูลใน pay-in ตามรายละเอียดด้านล่างนี้ด้วยนะคะ

Ref # 1:   123870
Ref # 2:   999A[CustomerCode]
```

**Values**:
- `Ref # 1`: **STATIC** - Always `123870` (same for all customers)
- `Ref # 2`: **DYNAMIC** - Format `999A[CustomerCode]` (e.g., `999A5411544`)

---

### Footer Notes (ALL Templates)

```
หมายเหตุ

กรณีหากการชำระเงินล่าช้า (เกินเวลาที่กำหนด) บริษัทฯ จะดำเนินการออกใบเพิ่มหนี้ต่อไป
การชำระเงินที่เคาน์เตอร์ธนาคาร (ธ.กรุงศรีอยุทธยา, ธ.ไทยพาณิชย์ และ ธ.กสิกรไทย) ก่อนเที่ยงของวันที่แจ้งยอด
และรบกวนส่งสำเนาใบโอนเงิน กลับมาที่ Email เดิมด้วยนะคะ
```

---

## Warning Text by Template

Warning text appears **BEFORE the transaction table** and is styled in **RED color**.

### Template A (Day 1-2) - Standard

**Warning Text**: *(none)*

No warning text for standard reminders.

---

### Template B (Day 3) - MI Warning

**Warning Text**:
```
หมายเหตุ – ถ้าลูกค้าชำระวันนี้ ก็จะไม่มีการ charge MI ค่ะ
```

**Meaning**: "Note - If the customer pays today, there will be no MI charge."

---

### Template C (Day 4+) - MI Coming Soon

**Warning Text**: *(none - warning moved to footer)*

**Footer Text** (replaces standard footer):
```
ท่านจะมียอดค่าใช้จ่าย MI ที่ต้องชำระเพิ่มเติม ซึ่งยอดดังกล่าวจะยังไม่ปรากฏในขณะนี้ และจะปรากฏเมื่อระบบดำเนินการอัปเดตข้อมูลเรียบร้อยแล้ว

หากมีข้อสงสัยกรุณาติดต่อเจ้าหน้าที่บัญชีดูแลตามพื้นที่ดังต่อไปนี้

-ภาคเหนือ : Jarukit.Panich@th.nestle.com
-ภาคตะวันออก, ภาคใต้, กรุงเทพ : Rungnapa.Machatree@th.nestle.com
-ภาคอีสาน, ภาคตะวันตก: Natthawan.Wanapermpool@th.nestle.com
```

**Meaning**: "You will have additional MI charges to pay. This amount is not yet displayed and will appear when the system completes the data update. If you have questions, please contact the AR representative for your region..."

---

### Template D (MI Posted) - MI Explanation

**Warning Text**: *(none - warning moved to footer)*

**Footer Text** (replaces standard footer):
```
ยอด MI ที่ปรากฎ เป็นใบเพิ่มหนี้ที่ท่านชำระบิลล่าช้า หากมีข้อสงสัยกรุณาติดต่อเจ้าหน้าที่บัญชีดูแลตามพื้นที่ดังต่อไปนี้

-ภาคเหนือ : Jarukit.Panich@th.nestle.com
-ภาคตะวันออก, ภาคใต้, กรุงเทพ : Rungnapa.Machatree@th.nestle.com
-ภาคอีสาน, ภาคตะวันตก: Natthawan.Wanapermpool@th.nestle.com
```

**Meaning**: "The MI amount shown is a debit note for late payment. If you have questions, please contact the AR representative for your region..."

---

## Transaction Table Format

### Table Columns

| Column | Header | Data Source | Format |
|--------|--------|-------------|--------|
| 1 | Account | `cr7bb_customercode` | Text |
| 2 | Name | `cr7bb_customername` | Text |
| 3 | Document Number | `cr7bb_documentnumber` | Text |
| 4 | Assignment | `cr7bb_assignment` | Text |
| 5 | Document Type | `cr7bb_documenttype` | Text (DR, DG, RV, MI, etc.) |
| 6 | Document Date | `cr7bb_documentdate` | dd/MM/yyyy |
| 7 | Amount in Local Currency | `cr7bb_amount` | Number with comma, 2 decimals |

### Table Styling

- **Header row**: Orange background (#D83B01), white text
- **Data rows**: Standard styling, NO row highlighting
- **Amount column**: Right-aligned, comma-separated with 2 decimal places
- **Total row**: Bold, right-aligned amount

### Important Notes

- **NO highlighted rows** - Even MI documents should NOT be highlighted
- Numbers must include comma separators (e.g., `2,513,838.51`)
- All amounts show 2 decimal places (e.g., `145,200.70` not `145200.7`)

---

## QR Code Section

### When QR Code is Available

Display both PromptPay QR and Bill Payment sections:

```
┌─────────────────┬─────────────────────────────────────────────┐
│   Promptpay     │               Bill payment                  │
│                 │                                             │
│   [QR IMAGE]    │ รบกวนเติมข้อมูลใน pay-in ตามรายละเอียดด้านล่างนี้    │
│                 │ ด้วยนะคะ                                     │
│   [CustCode]    │                                             │
│                 │ Ref # 1: XXXXXX                             │
│                 │ Ref # 2: 999AXXXXXXX                        │
└─────────────────┴─────────────────────────────────────────────┘
```

### When QR Code is NOT Available

Display Bill Payment section only (no PromptPay section):

```
┌─────────────────────────────────────────────────────────────┐
│                      Bill payment                           │
│                                                             │
│ รบกวนเติมข้อมูลใน pay-in ตามรายละเอียดด้านล่างนี้ด้วยนะคะ            │
│                                                             │
│ Ref # 1: XXXXXX                                             │
│ Ref # 2: 999AXXXXXXX                                        │
└─────────────────────────────────────────────────────────────┘
```

**Rule**: Show everything except QR image when QR is not available.

### QR Code Display Method

QR code is displayed **inline** using base64 encoding:

```html
<img src="data:image/jpeg;base64,[QR_BASE64_CONTENT]"
     alt="PromptPay QR Code"
     style="max-width:200px;" />
```

---

## HTML Styling Reference

### Warning Text (RED)

```html
<p style="color: #D83B01; font-weight: bold;">
  [Warning Text Here]
</p>
```

### Footer หมายเหตุ (RED heading)

```html
<p style="color: #D83B01; font-weight: bold;">หมายเหตุ</p>
<p>
  กรณีหากการชำระเงินล่าช้า (เกินเวลาที่กำหนด) บริษัทฯ จะดำเนินการออกใบเพิ่มหนี้ต่อไป<br/>
  การชำระเงินที่เคาน์เตอร์ธนาคาร (ธ.กรุงศรีอยุทธยา, ธ.ไทยพาณิชย์ และ ธ.กสิกรไทย) ก่อนเที่ยงของวันที่แจ้งยอด<br/>
  และรบกวนส่งสำเนาใบโอนเงิน กลับมาที่ Email เดิมด้วยนะคะ
</p>
```

### Table Header

```html
<tr style="background-color: #D83B01; color: white;">
  <th>Account</th>
  <th>Name</th>
  ...
</tr>
```

### Amount Formatting

```html
<td style="text-align: right;">2,513,838.51</td>
```

---

## Summary Table

| Element | Template A | Template B | Template C | Template D |
|---------|------------|------------|------------|------------|
| **Condition** | Day 1-2 | Day 3 | Day 4+ | Has MI Doc |
| **Warning Text** | None | ✅ Before table | None | None |
| **Transaction Table** | ✅ | ✅ | ✅ | ✅ |
| **QR Section** | ✅ If available | ✅ If available | ✅ If available | ✅ If available |
| **Bill Payment** | ✅ Always | ✅ Always | ✅ Always | ✅ Always |
| **Footer** | Standard หมายเหตุ | Standard หมายเหตุ | **Regional contacts** | **Regional contacts** |

---

## Implementation Notes

### Power Automate Flow Updates Required

1. **Email Engine Flow**: Add template selection logic based on MaxArrearDays and HasMIDocument
2. **Email Sending Flow**: Update email body to use inline QR display
3. **EmailLog Table**: Add `cr7bb_templatetype` field (Choice: A/B/C/D)

### EmailLog Fields to Store

| Field | Purpose |
|-------|---------|
| `cr7bb_templatetype` | Which template was used (A/B/C/D) |
| `cr7bb_qrcodeincluded` | Whether QR was included (boolean) |
| `cr7bb_emailbodypreview` | Generated HTML body |

### Compose Action Required

Use **Compose** action to build HTML body, then reference in email:
- Power Automate's email editor reformats HTML
- Using Compose preserves exact HTML structure

```
Body: @{outputs('Compose_Email_Body')}
```

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-16 | Initial specification created from client templates |
| 2026-01-16 | Standardized: All templates include Bill Payment and Footer |
| 2026-01-16 | Clarified: Warning text position is BEFORE table |
| 2026-01-16 | Clarified: No row highlighting for any template |
| 2026-01-16 | Clarified: QR section hidden if not available, but Bill Payment always shown |
| 2026-01-16 | Added exact Thai text from client confirmation |
| 2026-01-18 | **v1.1**: Updated Ref # 1 to STATIC value (123870) |
| 2026-01-18 | **v1.1**: Added regional AR contacts to Template C footer |
| 2026-01-18 | **v1.1**: Added regional AR contacts to Template D footer |
| 2026-01-18 | **v1.1**: Moved Template C/D warning text to footer section |

---

**Approved By**: Client (via meeting confirmation)
**Implementation Status**: Ready for development

---

## Appendix: Full Template Examples

### Example: Template A (Day 1-2 - Standard)

**Customer**: 5411544 - Chuenchomtaveerat Co.,Ltd.
**Arrear Days**: 2

```
┌────────────────────────────────────────────────────────────────────────────┐
│ Subject: 5411544 Chuenchomtaveerat Co.,Ltd. รายละเอียดบิลวันที่ 18.01.2026    │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│ เรียนเจ้าของกิจการ                                                          │
│                                                                            │
│ ท่านสามารถชำระเงินได้ตามรายละเอียดข้างท้ายนี้                                    │
│                                                                            │
│ ┌──────────┬─────────────────────┬───────────┬──────────┬──────┬──────────┐│
│ │ Account  │ Name                │ Doc No    │ Assign   │ Type │ Amount   ││
│ ├──────────┼─────────────────────┼───────────┼──────────┼──────┼──────────┤│
│ │ 5411544  │ Chuenchomtaveerat   │ 900012345 │ INV-001  │ DR   │ 25,000.00││
│ │ 5411544  │ Chuenchomtaveerat   │ 900012346 │ INV-002  │ DR   │ 15,500.50││
│ ├──────────┴─────────────────────┴───────────┴──────────┴──────┼──────────┤│
│ │ 5411544 Chuenchomtaveerat Co.,Ltd.                           │40,500.50 ││
│ └──────────────────────────────────────────────────────────────┴──────────┘│
│                                                                            │
│ ┌─────────────────┬────────────────────────────────────────────┐           │
│ │   Promptpay     │              Bill payment                  │           │
│ │                 │                                            │           │
│ │   [QR IMAGE]    │ รบกวนเติมข้อมูลใน pay-in ตามรายละเอียดด้านล่างนี้   │           │
│ │                 │ ด้วยนะคะ                                    │           │
│ │   5411544       │                                            │           │
│ │                 │ Ref # 1:   123870                          │           │
│ │                 │ Ref # 2:   999A5411544                     │           │
│ └─────────────────┴────────────────────────────────────────────┘           │
│                                                                            │
│ หมายเหตุ                                                                    │
│                                                                            │
│ กรณีหากการชำระเงินล่าช้า (เกินเวลาที่กำหนด) บริษัทฯ จะดำเนินการออกใบเพิ่มหนี้ต่อไป    │
│ การชำระเงินที่เคาน์เตอร์ธนาคาร (ธ.กรุงศรีอยุทธยา, ธ.ไทยพาณิชย์ และ ธ.กสิกรไทย)      │
│ ก่อนเที่ยงของวันที่แจ้งยอด                                                      │
│ และรบกวนส่งสำเนาใบโอนเงิน กลับมาที่ Email เดิมด้วยนะคะ                           │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

### Example: Template B (Day 3 - MI Warning)

**Customer**: 5411544 - Chuenchomtaveerat Co.,Ltd.
**Arrear Days**: 3

```
┌────────────────────────────────────────────────────────────────────────────┐
│ Subject: 5411544 Chuenchomtaveerat Co.,Ltd. รายละเอียดบิลวันที่ 18.01.2026    │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│ เรียนเจ้าของกิจการ                                                          │
│                                                                            │
│ ท่านสามารถชำระเงินได้ตามรายละเอียดข้างท้ายนี้                                    │
│                                                                            │
│ ⚠️ หมายเหตุ – ถ้าลูกค้าชำระวันนี้ ก็จะไม่มีการ charge MI ค่ะ                    │  ← RED
│                                                                            │
│ ┌──────────┬─────────────────────┬───────────┬──────────┬──────┬──────────┐│
│ │ Account  │ Name                │ Doc No    │ Assign   │ Type │ Amount   ││
│ ├──────────┼─────────────────────┼───────────┼──────────┼──────┼──────────┤│
│ │ 5411544  │ Chuenchomtaveerat   │ 900012345 │ INV-001  │ DR   │ 25,000.00││
│ ├──────────┴─────────────────────┴───────────┴──────────┴──────┼──────────┤│
│ │ 5411544 Chuenchomtaveerat Co.,Ltd.                           │25,000.00 ││
│ └──────────────────────────────────────────────────────────────┴──────────┘│
│                                                                            │
│ ┌─────────────────┬────────────────────────────────────────────┐           │
│ │   Promptpay     │              Bill payment                  │           │
│ │   [QR IMAGE]    │ รบกวนเติมข้อมูลใน pay-in ...                 │           │
│ │   5411544       │ Ref # 1:   123870                          │           │
│ │                 │ Ref # 2:   999A5411544                     │           │
│ └─────────────────┴────────────────────────────────────────────┘           │
│                                                                            │
│ หมายเหตุ                                                                    │
│                                                                            │
│ กรณีหากการชำระเงินล่าช้า (เกินเวลาที่กำหนด) บริษัทฯ จะดำเนินการออกใบเพิ่มหนี้ต่อไป    │
│ การชำระเงินที่เคาน์เตอร์ธนาคาร ...                                              │
│ และรบกวนส่งสำเนาใบโอนเงิน กลับมาที่ Email เดิมด้วยนะคะ                           │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

### Example: Template C (Day 4+ - MI Coming Soon)

**Customer**: 5411544 - Chuenchomtaveerat Co.,Ltd.
**Arrear Days**: 5

```
┌────────────────────────────────────────────────────────────────────────────┐
│ Subject: 5411544 Chuenchomtaveerat Co.,Ltd. รายละเอียดบิลวันที่ 18.01.2026    │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│ เรียนเจ้าของกิจการ                                                          │
│                                                                            │
│ ท่านสามารถชำระเงินได้ตามรายละเอียดข้างท้ายนี้                                    │
│                                                                            │
│ ┌──────────┬─────────────────────┬───────────┬──────────┬──────┬──────────┐│
│ │ Account  │ Name                │ Doc No    │ Assign   │ Type │ Amount   ││
│ ├──────────┼─────────────────────┼───────────┼──────────┼──────┼──────────┤│
│ │ 5411544  │ Chuenchomtaveerat   │ 900012345 │ INV-001  │ DR   │ 25,000.00││
│ ├──────────┴─────────────────────┴───────────┴──────────┴──────┼──────────┤│
│ │ 5411544 Chuenchomtaveerat Co.,Ltd.                           │25,000.00 ││
│ └──────────────────────────────────────────────────────────────┴──────────┘│
│                                                                            │
│ ┌─────────────────┬────────────────────────────────────────────┐           │
│ │   Promptpay     │              Bill payment                  │           │
│ │   [QR IMAGE]    │ รบกวนเติมข้อมูลใน pay-in ...                 │           │
│ │   5411544       │ Ref # 1:   123870                          │           │
│ │                 │ Ref # 2:   999A5411544                     │           │
│ └─────────────────┴────────────────────────────────────────────┘           │
│                                                                            │
│ ท่านจะมียอดค่าใช้จ่าย MI ที่ต้องชำระเพิ่มเติม ซึ่งยอดดังกล่าวจะยังไม่ปรากฏในขณะนี้    │
│ และจะปรากฏเมื่อระบบดำเนินการอัปเดตข้อมูลเรียบร้อยแล้ว                            │
│                                                                            │
│ หากมีข้อสงสัยกรุณาติดต่อเจ้าหน้าที่บัญชีดูแลตามพื้นที่ดังต่อไปนี้                     │
│                                                                            │
│ -ภาคเหนือ : Jarukit.Panich@th.nestle.com                                   │
│ -ภาคตะวันออก, ภาคใต้, กรุงเทพ : Rungnapa.Machatree@th.nestle.com            │
│ -ภาคอีสาน, ภาคตะวันตก: Natthawan.Wanapermpool@th.nestle.com                 │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

### Example: Template D (MI Posted - MI Explanation)

**Customer**: 5411544 - Chuenchomtaveerat Co.,Ltd.
**Has MI Document**: Yes

```
┌────────────────────────────────────────────────────────────────────────────┐
│ Subject: 5411544 Chuenchomtaveerat Co.,Ltd. รายละเอียดบิลวันที่ 18.01.2026    │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│ เรียนเจ้าของกิจการ                                                          │
│                                                                            │
│ ท่านสามารถชำระเงินได้ตามรายละเอียดข้างท้ายนี้                                    │
│                                                                            │
│ ┌──────────┬─────────────────────┬───────────┬──────────┬──────┬──────────┐│
│ │ Account  │ Name                │ Doc No    │ Assign   │ Type │ Amount   ││
│ ├──────────┼─────────────────────┼───────────┼──────────┼──────┼──────────┤│
│ │ 5411544  │ Chuenchomtaveerat   │ 900012345 │ INV-001  │ DR   │ 25,000.00││
│ │ 5411544  │ Chuenchomtaveerat   │ 900099999 │ MI-001   │ MI   │  1,250.00││  ← MI doc
│ ├──────────┴─────────────────────┴───────────┴──────────┴──────┼──────────┤│
│ │ 5411544 Chuenchomtaveerat Co.,Ltd.                           │26,250.00 ││
│ └──────────────────────────────────────────────────────────────┴──────────┘│
│                                                                            │
│ ┌─────────────────┬────────────────────────────────────────────┐           │
│ │   Promptpay     │              Bill payment                  │           │
│ │   [QR IMAGE]    │ รบกวนเติมข้อมูลใน pay-in ...                 │           │
│ │   5411544       │ Ref # 1:   123870                          │           │
│ │                 │ Ref # 2:   999A5411544                     │           │
│ └─────────────────┴────────────────────────────────────────────┘           │
│                                                                            │
│ ยอด MI ที่ปรากฎ เป็นใบเพิ่มหนี้ที่ท่านชำระบิลล่าช้า                               │
│ หากมีข้อสงสัยกรุณาติดต่อเจ้าหน้าที่บัญชีดูแลตามพื้นที่ดังต่อไปนี้                     │
│                                                                            │
│ -ภาคเหนือ : Jarukit.Panich@th.nestle.com                                   │
│ -ภาคตะวันออก, ภาคใต้, กรุงเทพ : Rungnapa.Machatree@th.nestle.com            │
│ -ภาคอีสาน, ภาคตะวันตก: Natthawan.Wanapermpool@th.nestle.com                 │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## Regional AR Contact Reference

| Region | Contact | Email |
|--------|---------|-------|
| ภาคเหนือ (North) | Jarukit Panich | Jarukit.Panich@th.nestle.com |
| ภาคตะวันออก, ภาคใต้, กรุงเทพ (East, South, Bangkok) | Rungnapa Machatree | Rungnapa.Machatree@th.nestle.com |
| ภาคอีสาน, ภาคตะวันตก (Northeast, West) | Natthawan Wanapermpool | Natthawan.Wanapermpool@th.nestle.com |
