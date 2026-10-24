---
name: Precision Industrial
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
  headline-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
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
    lineHeight: 18px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
  tabular-data:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
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
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style

This design system serves small manufacturing facilities, job shops, and trading hubs that require immediate operational clarity over aesthetic flourish. The visual tone is utilitarian, disciplined, and reliable—evoking the calibrated control of industrial machinery and lean warehouse operations.

The design movement is **Modern Utilitarian**: dense, structured, highly scannable, and stripped of extraneous decoration. Interfaces prioritize high information density, unambiguous status signaling, and zero latency in cognitive processing. Workflows frequently occur in high-glare warehouse floors or cramped front offices, demanding crisp lines, distinct boundaries, and explicit contrast ratios.

## Colors

The palette balances deep industrial teals with functional operational states. Surfaces remain cool and bright to keep dense tables and inventory matrices readable.

### Functional Palette
- **Canvas Background**: `#F8FAFC` (Slate 50) establishes a clean, glare-reducing foundation across operational workspaces.
- **Card & Table Surface**: `#FFFFFF` provides stark contrast against data grids and record forms.
- **Structural Border**: `#E2E8F0` defines cards, dividers, and table rows with a crisp 1px boundary.
- **Primary Brand / Action**: `#0D5C75` (Deep Slate Teal) anchors navigation, primary commit actions, and active selection states.
- **Secondary / Supporting**: `#0F766E` (Teal) handles secondary interactive triggers, batch workflows, and filtered states.
- **Text Primary**: `#0F172A` delivers high-contrast legibility for SKUs, pricing, part numbers, and critical readouts.
- **Text Secondary**: `#475569` supports metadata, table column headers, and helper descriptions.

### Status Indicators
- **Critical / Danger**: `#B91C1C` for backorders, machinery faults, threshold breaches, and destructive actions.
- **Warning / Alert**: `#B45309` for pending inspections, low inventory thresholds, and unallocated purchase orders.
- **Success / Healthy**: `#15803D` for fulfilled shipments, reconciled invoices, and active production runs.

## Typography

Inter provides uniform mechanical precision and optical legibility at compact sizes. Data display rules are strictly enforced:

- Enable tabular figures (`font-feature-settings: "tnum" 1`) across all numerical metrics, order totals, quantities, inventory units, and timestamps.
- Headers remain tight and compact to preserve vertical layout capacity for table rows and job tickets.
- Data table column headers utilize `label-sm` with uppercase transformation and letter spacing to distinguish structural framing from row records.

## Layout & Spacing

The layout is built on an adaptive fluid grid structured for dashboard views, inventory spreadsheets, and multi-step dispatch screens.

- **Desktop (1024px+)**: 12-column grid with `1rem` gutters and `1.5rem` screen margins. Supports multi-column form cards and dense two-pane master-detail workflows.
- **Tablet (768px - 1023px)**: 8-column grid with `1rem` gutters. Side panels collapse into off-canvas drawers; metrics cards wrap to 2-per-row.
- **Mobile (Below 768px)**: 4-column grid with `0.75rem` gutters and `1rem` outer screen padding. Complex tables transition into structured item-card lists with stacked metadata.

Component gaps favor compact rhythm: `space-xs` (4px) separates tight icon-text clusters, `space-sm` (8px) separates form labels from input controls, and `space-md` (12px) structures card internal groups.

## Elevation & Depth

This design system avoids blurry layered dropshadows and skeuomorphic gradients in favor of **low-contrast outlines and structural flat planes**.

- **Level 0 (Base)**: `#F8FAFC` raw screen background.
- **Level 1 (Card/Container)**: Pure white (`#FFFFFF`) with a strict `1px solid #E2E8F0` border. Zero drop-shadow.
- **Level 2 (Dropdowns & Popovers)**: `#FFFFFF` surface with `1px solid #CBD5E1` border and a direct, minimal ambient shadow (`0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.06)`).
- **Level 3 (Modals & Overlays)**: `#FFFFFF` surface framed by `1px solid #94A3B8`, mounted over a fixed scrim of `rgba(15, 23, 42, 0.45)`.

## Shapes

The geometric architecture relies on rigid, calibrated industrial corners:

- **Standard Containers, Buttons & Inputs**: Fixed `4px` corner radius. This applies universally to cards, form inputs, action buttons, dropdown panels, and table shells.
- **Status & Metric Badges**: Explicitly set to pill-shaped radius (`9999px`) to create clear geometric contrast against rectangular operational records.
- **Avatars**: Pure circular geometry (`50%` / `9999px`) to isolate user and operator identities from rectangular data fields.

## Components

### Buttons
- **Primary**: Background `#0D5C75`, text `#FFFFFF`, radius `4px`, height `36px` (compact: `32px`). Hover: `#0A485C`. Focus: 2px ring `#0D5C75` with 2px white offset. Active: scale 0.99.
- **Secondary**: Background `#FFFFFF`, text `#0F172A`, border `1px solid #E2E8F0`, radius `4px`. Hover: background `#F8FAFC`, border `#CBD5E1`.
- **Destructive**: Background `#B91C1C`, text `#FFFFFF`, radius `4px`. Hover: `#991B1B`.

### Input Fields & Controls
- **Text / Number Inputs**: Height `36px`, background `#FFFFFF`, border `1px solid #CBD5E1`, radius `4px`, padding `0 12px`, text `body-md` (`#0F172A`). Placeholder: `#94A3B8`. Focus: border `#0D5C75` with 1px outline `#0D5C75`.
- **Checkboxes & Radios**: 16px × 16px square (checkbox) or circle (radio), border `1px solid #94A3B8`, radius `3px` (checkbox) or `50%` (radio). Checked: background `#0D5C75`, border `#0D5C75` with white checkmark.

### Badges & Pill Chips
- **Status Badges**: Radius `9999px`, height `22px`, padding `0 8px`, typography `label-sm`.
  - *Healthy/Success*: Background `#DCFCE7`, text `#15803D`.
  - *Warning/Amber*: Background `#FEF3C7`, text `#B45309`.
  - *Critical/Red*: Background `#FEE2E2`, text `#B91C1C`.
  - *Neutral/Info*: Background `#F1F5F9`, text `#475569`.

### User & Operator Avatars
- **Initials Avatar**: 32px × 32px circular badge (`border-radius: 9999px`). Background generated from operator ID hashing using industrial slate/teal hues (`#0D5C75`, `#0F766E`, `#334155`, `#475569`). Centered uppercase text `label-sm` in `#FFFFFF`.

### Cards & Work Order Surfaces
- Flat `#FFFFFF` surface with `1px solid #E2E8F0` border and `4px` corner radius. Inner padding strictly `space-md` (12px) for high density or `space-lg` (20px) for summary reports. Never apply ambient blur or soft shadows.

### Tables & Inventory Data Grids
- **Header Row**: Height `36px`, background `#F8FAFC`, border-bottom `1px solid #E2E8F0`, typography `label-sm` in `#475569`.
- **Data Rows**: Height `40px` (dense: `34px`), background `#FFFFFF`, border-bottom `1px solid #F1F5F9`. Hover state: `#F8FAFC`. Monospace or tabular figures applied to SKU, stock, and currency columns.