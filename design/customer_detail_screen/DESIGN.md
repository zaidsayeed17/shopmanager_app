---
name: Ledger Slate
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#40484c'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#70787d'
  outline-variant: '#bfc8cd'
  surface-tint: '#1e667f'
  primary: '#004357'
  on-primary: '#ffffff'
  primary-container: '#0d5c75'
  on-primary-container: '#93d3ef'
  inverse-primary: '#90cfec'
  secondary: '#006a63'
  on-secondary: '#ffffff'
  secondary-container: '#99efe5'
  on-secondary-container: '#006f67'
  tertiary: '#692c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#8d3e00'
  on-tertiary-container: '#ffbb97'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#bde9ff'
  primary-fixed-dim: '#90cfec'
  on-primary-fixed: '#001f2a'
  on-primary-fixed-variant: '#004d64'
  secondary-fixed: '#9cf2e8'
  secondary-fixed-dim: '#80d5cb'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#00504a'
  tertiary-fixed: '#ffdbca'
  tertiary-fixed-dim: '#ffb68e'
  on-tertiary-fixed: '#331200'
  on-tertiary-fixed-variant: '#763300'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0em
  amount-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  amount-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: -0.01em
  amount-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.5rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
  space-2xl: 2rem
---

## Brand & Style

The design system is engineered for the high-velocity, high-accountability world of small manufacturing plants, workshops, and trading firms. The visual tone balances industrial utility with financial precision. Rather than resembling a generic tech dashboard, it adopts the tactile certainty and reliability of a physical ledger, modernized for quick touch-and-tap workflows in shop floors and trading desks.

Key Tenets:
- **Utilitarian Rigor:** Form strictly follows function. Visual flourish is stripped away in favor of high-contrast typography, strict rectangular architecture, and rapid operational clarity.
- **Financial Confidence:** Numeric values, currency signs (₹), and balances are treated as first-class citizens with tabular figures, distinct signifiers for Credit/Debit, and legible status indicators.
- **Contextual Mobility:** Quick-trigger actions (direct WhatsApp sharing for invoices, instant calling for payment collection) are integrated directly into transaction lists and customer ledgers without obscuring core data.

## Colors

The palette establishes an immediate atmosphere of fiscal integrity, grounded operational order, and unmistakable status recognition.

- **Primary (`#0D5C75`):** Deep slate teal anchor used for primary calls to action, active navigation tabs, table header bands, and structural identity.
- **Secondary (`#0F766E`):** Rich teal utilized for secondary interactive elements, selected filters, and operational highlights.
- **Ledger Status Tokens:**
  - **Credit / Inflow / Success (`#15803D`):** Crisp, deep forest green denoting incoming cash, settled accounts ("Paid"), and positive balance additions.
  - **Debit / Outflow / Critical (`#B91C1C`):** Strict crimson red signaling dues owed ("Unpaid"), material waste, or system alerts.
  - **Pending / Warning (`#B45309`):** Dense amber marking partial settlements ("Partial"), stock reorder warnings, and draft orders.
- **Surfaces & Layout:**
  - Base canvas: `#F8FAFC` (Cool slate tint preventing eye fatigue under harsh industrial tube lighting).
  - Container surfaces: `#FFFFFF` encased in deliberate `1px solid #E2E8F0` borders.
  - Text Hierarchy: Primary `#0F172A` (near-black slate for maximum contrast) and Secondary `#475569` for unit labels, metadata, and timestamps.

## Typography

The design system relies entirely on Inter. To maintain absolute bookkeeping accuracy across columns of raw figures, all numeric representations (monetary metrics, stock counts, batch numbers, dates) must enforce OpenType tabular figures (`font-variant-numeric: tabular-nums; font-feature-settings: "tnum" 1`).

- **Currency Treatment:** The Indian Rupee symbol (₹) is rendered at the exact font-weight of the adjacent figure to guarantee optical weight equivalence.
- **Labels & Metas:** `label-sm` utilizes uppercase transform with deliberate tracking (`0.04em`) for compact table headers, tax categories, and manufacturing batch tags.
- **Readability Rules:** Tight line heights are favored across numeric headers to maintain dense information display without horizontal overflow.

## Layout & Spacing

A compact, information-dense 12-column responsive layout anchors desktop views, folding into a single vertical stream for handheld tablet and phone viewports.

- **Information Density:** Spacing tokens prioritize zero wasted screen real estate. Data rows default to a compact vertical padding of `space-sm` (8px) or `space-md` (12px), enabling floor managers to view dozens of purchase orders, stock lines, or party balances without excessive scrolling.
- **Grid Structure:** Desktop layouts utilize fixed sidebar navigation (240px) with a fluid content area flanked by `margin` (24px) and internal `gutter` (16px).
- **Mobile Handheld Adaptation:** On devices below 768px, page canvas margins compress to `margin-mobile` (16px), floating action docks pin to the bottom for primary entry ("+ New Sale", "+ Add Stock"), and horizontal scrolling is enabled for multi-column balance sheets.

## Elevation & Depth

This design system rejects heavy blurs, translucent glass effects, and colored drop-shadows. Depth is established through **structural containment** and **low-contrast architectural outlines**.

- **Surfaces:** Cards, ledger rows, and forms sit flat against `#F8FAFC` on `#FFFFFF` planes.
- **Borders over Shadows:** All containers rely on a deterministic `1px solid #E2E8F0` border to demarcate boundaries. 
- **Floating Modals & Overlays:** Where elevated focus is strictly necessary (e.g., payment entry dialogs, quick receipt previews), use a singular utilitarian shadow:
  - `box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.06);`
- **Active Table & Row Hover:** Data list items utilize an immediate background shift to `#F1F5F9` on pointer focus rather than physical elevation.

## Shapes

The geometric identity is defined by a strict dual-radius rule:

1. **The 4px Structural Standard (`roundedness: 1`):** All interactive cards, table wrappers, input fields, dropdown menus, modals, and buttons have a crisp, engineered `4px` radius. This maintains an orderly, business-to-business feel reminiscent of technical machinery and physical balance books.
2. **The Status Capsule Exception:** Strictly and only status badges ("Paid", "Unpaid", "Partial", "Overdue", "Active", "Inactive") use full pill geometry (`border-radius: 9999px`). This deliberate visual contrast instantly differentiates static statuses from interactive, box-like controls.

## Components

### Buttons
- **Primary:** Background `#0D5C75`, text `#FFFFFF`, 4px border radius, font `label-md`. Hover state darkens by 8%. No drop shadow. Height: 36px (compact) or 42px (touch standard).
- **Secondary / Utility:** Background `#FFFFFF`, border `1px solid #CBD5E1`, text `#0F172A`.
- **Quick Action Triggers (Call & WhatsApp):**
  - **WhatsApp Action:** Soft emerald background (`#ECFDF5`), border `1px solid #A7F3D0`, text `#047857`, featuring an inline chat icon for single-tap invoice dispatches.
  - **Call Action:** Soft slate background (`#F1F5F9`), border `1px solid #CBD5E1`, text `#334155`, for instantaneous dialing of clients with overdue receivables.

### Status Badges (Pills)
- Height: 22px, padding `0 10px`, border radius `9999px`, font `label-sm`.
- **Paid / Completed:** Background `#DCFCE7`, text `#15803D`, border `1px solid #86EFAC`.
- **Unpaid / Overdue:** Background `#FEE2E2`, text `#B91C1C`, border `1px solid #FCA5A5`.
- **Partial / Pending:** Background `#FEF3C7`, text `#B45309`, border `1px solid #FCD34D`.
- **Inactive / Draft:** Background `#F1F5F9`, text `#64748B`, border `1px solid #CBD5E1`.

### Data Tables & Ledger Lists
- **Container:** Wrapped in `#E2E8F0` 1px border with `4px` outer radius.
- **Header:** Background `#F8FAFC`, uppercase `label-sm` text `#475569`, border bottom `1px solid #E2E8F0`.
- **Row:** Height: 44px, alternating white surface, hover transition to `#F8FAFC`.
- **Numeric Columns:** Right-aligned, tabular numerals, with explicit color-coding for money: Credit entries in `#15803D` prefixed with `+ ₹`, Debit entries in `#B91C1C` prefixed with `- ₹`.

### Form Fields & Inputs
- **Base Style:** Background `#FFFFFF`, 1px border `#CBD5E1`, 4px border radius, font `body-md` (`#0F172A`).
- **Focus State:** 1px border `#0D5C75` with sharp, solid `0 0 0 1px #0D5C75` ring.
- **Currency Field Extension:** An integrated `#F1F5F9` prefix cell locked to `₹` preceding the input for error-free amount entry.

### Cards & Summary Blocks
- Background `#FFFFFF`, border `1px solid #E2E8F0`, 4px border radius, padding `space-lg`.
- **Metric Cards:** Display metric label in `label-sm` muted text, followed by bold amount in `amount-lg`, finished with a footer showing trend or party count.