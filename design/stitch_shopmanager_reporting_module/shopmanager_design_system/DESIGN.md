---
name: ShopManager Design System
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
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  title-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: '0'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: '0'
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: '0'
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: '0'
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
  currency-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: '0'
  currency-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system is engineered specifically for Indian Small and Medium Businesses (SMBs) across manufacturing, wholesale, and trading sectors. The target users are business owners, plant operators, dispatch managers, and accountants who prioritize dense information architecture, rapid ledger entry, high-contrast legibility, and zero-distraction utility. 

The aesthetic is **Corporate / Modern Utility**: clean, grounded, and rigorous. It strips away decorative fluff in favor of structural clarity, dense tabular displays, and deliberate semantic color accents. The UI evokes reliability, precision, financial accountability, and unyielding speed under daylight or dusty factory floor conditions.

## Colors

The palette establishes an authoritative, high-contrast operational environment optimized for data scrutiny.

- **Primary (`#0D5C75`)**: Deep Slate Teal. Used for primary actions, active navigational states, and master key points.
- **Secondary (`#0F766E`)**: Deep Teal. Applied to secondary workflows, supporting badges, and contextual focal points.
- **Tertiary / Warning (`#B45309`)**: Amber. Dedicated to pending GST filings, low stock thresholds, and operational warnings.
- **Critical / Danger (`#B91C1C`)**: Deep Crimson. Reserved for overdue invoices, destructive actions, and payment failures.
- **Success (`#15803D`)**: Forest Green. Designates paid vouchers, settled balances, and verified stock reconciliations.
- **Surfaces & Neutral**: Canvas background is strictly `#F8FAFC`, card and panel surfaces are `#FFFFFF` bound by `#E2E8F0` hairline borders. Primary typography uses `#0F172A` with `#475569` for secondary metadata and table headers.

## Typography

The type system relies on `Inter` across all structural layers to maximize legibility in dense forms and financial tables.

### Numerical and Currency Formatting
- Apply OpenType tabular figures (`font-feature-settings: 'tnum' 1`) to all monetary and inventory quantities.
- Values formatted in Indian Rupee (`₹`) must follow the Indian numbering system convention (`₹12,34,567.00` with lakh and crore delimitations).
- Currency symbols must render at equivalent optical weight to the trailing integers to prevent vertical misalignment in ledger rows.

## Layout & Spacing

The layout is built on a fluid, utility-first grid designed for dense enterprise productivity:

- **Desktop (1024px+)**: 12-column layout with fixed 240px collapsable navigation sidebar, 16px gutters, and 24px container margins. Tables use tight horizontal padding to maximize data fields per viewport.
- **Tablet (768px - 1023px)**: 8-column layout with 16px gutters and 16px margins; navigation compresses to an icon-only dock or slide-over drawer.
- **Mobile (< 768px)**: 4-column layout with 12px gutters and 12px margins. Complex tabular ledgers switch to structured card stacks with key-value data rows.
- **Rhythm**: Spacing follows a strict 4px base scale. Inner component spacing prioritizes tight visual density (`space-xs` for inline tag gaps, `space-sm` for field padding, and `space-md` for grouped items).

## Elevation & Depth

This system intentionally relies on **low-contrast outlines** over drop shadows to preserve readability under high ambient light and maintain a clean tabular ledger feel:

- **Base Surfaces**: `#FFFFFF` cards and panels rest flat on the `#F8FAFC` background, defined solely by a crisp `1px solid #E2E8F0` border.
- **Layer 1 (Dropdowns, Popovers, Context Menus)**: Elevated with `1px solid #CBD5E1` and a disciplined ambient shadow: `0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.06)`.
- **Layer 2 (Modals, Slide-over Drawers)**: Backed by a high-contrast dimming scrim (`rgba(15, 23, 42, 0.40)`) and a deep containment shadow: `0 20px 25px -5px rgba(15, 23, 42, 0.12), 0 8px 10px -6px rgba(15, 23, 42, 0.08)`.
- **Table Sticky Headers**: `border-bottom: 2px solid #E2E8F0` with a subtle elevation transition when scrolling.

## Shapes

The geometric framework is strict and industrial. 

A uniform **4px border-radius (`roundedness: 1`)** is enforced across all core interactive and grouping elements—including action buttons, text inputs, selects, table containers, and card panels. Badges and status pills utilize the same 4px radius (or a maximum of 6px) to avoid playful pill geometries and sustain an uncompromising enterprise tone.

## Components

### Buttons
- **Primary**: Background `#0D5C75`, text `#FFFFFF`, border `none`, border-radius `4px`, height `36px`, padding `0 14px`, typography `label-md`. Hover: `#0A475B`. Active: `#073544`. Focus: 2px outline offset with `#0D5C75`.
- **Secondary / Outline**: Background `#FFFFFF`, text `#0D5C75`, border `1px solid #0D5C75`, border-radius `4px`, height `36px`. Hover: `#F0FDF4`.
- **Destructive**: Background `#B91C1C`, text `#FFFFFF`, border-radius `4px`. Hover: `#991B1B`.

### Form Inputs & Selects
- Height `36px`, border `1px solid #CBD5E1`, background `#FFFFFF`, border-radius `4px`, padding `0 10px`, typography `body-md` (`#0F172A`).
- Focus state: `border-color: #0D5C75`, with an outline `0 0 0 1px #0D5C75`.
- Error state: `border-color: #B91C1C`, subtext typography `body-sm` in `#B91C1C`.

### Cards & Panels
- Background `#FFFFFF`, border `1px solid #E2E8F0`, border-radius `4px`, padding `16px`. Headers within cards include a bottom dividing border of `1px solid #F1F5F9`.

### Data Tables & Ledgers
- Dense layout with row height `40px` (standard) or `32px` (compact ledger mode).
- Header row: background `#F8FAFC`, text `#475569`, uppercase `label-sm`, bottom border `2px solid #E2E8F0`.
- Data rows: text `#0F172A`, bottom border `1px solid #F1F5F9`. Numeric and currency columns must align right.

### Status Badges & Chips
- Border-radius `4px`, padding `2px 6px`, typography `label-sm`.
- **Success (Settled/Delivered)**: Background `#DCFCE7`, text `#15803D`, border `1px solid #86EFAC`.
- **Warning (Pending/Part-paid)**: Background `#FEF3C7`, text `#B45309`, border `1px solid #FCD34D`.
- **Critical (Overdue/Cancelled)**: Background `#FEE2E2`, text `#B91C1C`, border `1px solid #FCA5A5`.

### Specialized SMB Components
- **GSTIN & E-Way Bill Input**: Monospace-formatted field with automatic uppercase transform and checksum validation indicator.
- **Voucher Ledger Row**: Compound row featuring debit/credit columns, inline balance tally, and Indian numbering format tags.