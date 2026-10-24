---
name: Ledger & Slate
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
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
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
    letterSpacing: -0.005em
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
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.005em
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.015em
  label-xs:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
  mono-data:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
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
  gutter-lg: 1.5rem
  margin: 1rem
  margin-md: 1.5rem
  margin-lg: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system is engineered for operational clarity, precision, and business confidence. Built for merchants, operators, and business managers, the interface communicates reliability, structured accounting rigor, and decisive executive control.

The visual style unites **Modern Corporate** structure with a **Printable Ledger Aesthetic**. Surfaces echo high-grade physical invoices, archival manifests, and crisp paper records—translated seamlessly into a high-density, low-latency web application. Interactions are direct and unembellished; typography and tabular geometry drive hierarchy rather than decorative illustrations. The user experience prioritizes scan-efficiency, unambiguous numerical reads, and deterministic transaction workflows.

## Colors

The palette establishes an authoritative, document-inspired atmosphere using balanced architectural slates, precise teals, and explicit transactional state indicators.

### Core Swatches
- **Primary (`#0D5C75`)**: Deep Slate Teal. Anchors brand headers, primary command actions, selected navigational landmarks, and key totals.
- **Secondary (`#0F766E`)**: Muted Pine / Deep Cyan. Used for supporting action triggers, tab highlights, active filters, and informational indicators.
- **Neutral Primary (`#0F172A`)**: Slate 900. High-contrast ink tone for primary data values, invoice numbers, currency readings, and prominent headers.
- **Neutral Secondary (`#475569`)**: Slate 600. Secondary text for metadata labels, column headers, timestamps, and supplementary descriptions.
- **Surface Canvas (`#F8FAFC`)**: Slate 50. Flat architectural ground layer providing contrast beneath pure white paper surfaces.
- **Surface Card (`#FFFFFF`)**: Pure White. Physical document and card surfaces.
- **Surface Border (`#E2E8F0`)**: Slate 200. Structural 1px hairline rule defining all ledger panes, cards, and cell divisions.

### Semantic Status Colors
State tokens strictly govern monetary reconciliation and operational workflows:
- **Success / Paid (`#15803D`)**: Rich emerald green. Used for completed payments, settled balances, and positive margins. Paired with background `#F0FDF4` and border `#BBF7D0`.
- **Warning / Partial (`#B45309`)**: Warm amber. Used for partial disbursements, pending clearing, and items requiring attention. Paired with background `#FFFBEB` and border `#FDE68A`.
- **Critical / Unpaid (`#B91C1C`)**: Crisp crimson red. Used for past-due invoices, unpaid obligations, and systemic errors. Paired with background `#FEF2F2` and border `#FECACA`.

## Typography

Typography is set exclusively in **Inter** to ensure maximum legibility across dense tabular layouts, nested data trees, and printable receipts.

- **Tabular Alignment**: All numbers, currency symbols, and tracking codes must be set with OpenType tabular figures (`tnum`) enabled via font features. This guarantees that columns of numeric totals, tax figures, and line items align cleanly.
- **Section Headers & Tables**: Column headers and metadata titles utilize `label-xs` in uppercase tracking (`letter-spacing: 0.04em`) with `#475569` to emulate traditional ledger column headings.
- **Hierarchy & Contrast**: Hierarchy is maintained by alternating font weight (400, 500, 600, 700) rather than disproportionately large font jumps, ensuring visual density remains stable across invoice layouts.

## Layout & Spacing

The layout model implements a structured, fluid grid system framed inside a fixed printable boundary for record manifests.

- **Grid Structure**: A standard 12-column grid system is used on desktop displays (`>1024px`), moving to an 8-column layout on tablets (`768px - 1023px`), and a 4-column stack on mobile devices (`<768px`).
- **Invoice & Record Dimensions**: Detailed record sheets conform to a maximum content width of `1120px` to mirror physical A4/Letter ratios when displayed or generated as print previews.
- **Density Rules**: Spacing follows a compact 4px mathematical base unit (`0.25rem`). Data grids and order sheets employ tight vertical padding (`space-xs` and `space-sm`) to maximize visible information per viewport, while outer module bounds use `space-lg` and `space-xl` to prevent cognitive fatigue.
- **Responsive Adaptations**: On mobile views, tabular ledgers reflow into vertically stacked card records, while gutters compress from `1.5rem` down to `1rem` to conserve critical horizontal area.

## Elevation & Depth

Visual hierarchy relies on **Low-Contrast Outlines** and crisp planes rather than atmospheric shadows, producing a tangible, printable-record quality.

- **Zero-Shadow Default**: Cards, tables, inputs, and static panels do not use box shadows. Boundaries are drawn using a razor-sharp 1px border (`#E2E8F0`).
- **Stacked Paper Depth**: When secondary documents, slide-out panels, or transactional drawers overlay the main view, depth is conveyed using a discrete, subtle shadow: `0 4px 6px -1px rgba(15, 23, 42, 0.05), 0 2px 4px -2px rgba(15, 23, 42, 0.05)`.
- **Modals & Overlays**: Critical confirmation dialogs use an intentional backdrop veil of `#0F172A` with 35% opacity, paired with an elevation shadow of `0 10px 15px -3px rgba(15, 23, 42, 0.08), 0 4px 6px -4px rgba(15, 23, 42, 0.04)` to bring the focal card forward without softening edges.

## Shapes

The geometric architecture relies on disciplined, low-radius rectilinearity paired with targeted pill elements for transient metadata.

- **Structural Elements (4px Radius)**: All cards, containers, buttons, input fields, dropdown menus, and data tables apply an explicit 4px corner radius (`0.25rem`). This preserves the formal, paper-cut precision suitable for balance sheets, purchase orders, and item inventories.
- **Status & Badges (Pill Shape)**: Status badges (e.g., Paid, Partial, Unpaid) break the rectilinear grid by utilizing full pill curvature (`border-radius: 9999px`). This differentiation allows the human eye to immediately classify status indicators apart from structural fields and actionable controls.

## Components

### Buttons
- **Primary Button**: Background `#0D5C75`, text `#FFFFFF`, border none, radius 4px, height 36px (compact) or 40px (default), font `label-md`. Hover state `#0A485C`, active `#083B4B`. Focus ring: 2px offset with `#0D5C75`.
- **Secondary Button**: Background `#FFFFFF`, text `#0F172A`, 1px border `#E2E8F0`, radius 4px. Hover state background `#F8FAFC` and border `#CBD5E1`.
- **Destructive Button**: Background `#FFFFFF`, text `#B91C1C`, 1px border `#FECACA`, radius 4px. Hover state background `#FEF2F2`.

### Status Badges (Pills)
All status badges are set with `border-radius: 9999px`, padding `2px 10px`, font `label-xs` uppercase:
- **Paid**: Background `#F0FDF4`, border `1px solid #BBF7D0`, text `#15803D`. Optional 6px solid circular green pip before text.
- **Partial**: Background `#FFFBEB`, border `1px solid #FDE68A`, text `#B45309`. Optional 6px solid circular amber pip before text.
- **Unpaid**: Background `#FEF2F2`, border `1px solid #FECACA`, text `#B91C1C`. Optional 6px solid circular red pip before text.

### Cards & Invoices
- **Card Surface**: Background `#FFFFFF`, 1px solid border `#E2E8F0`, 4px corner radius, padding `space-md` to `space-lg`.
- **Card Header**: Border-bottom `1px solid #E2E8F0`, padding-bottom `space-sm`, title set in `headline-sm` with color `#0F172A`.
- **Card Summary Footer**: Muted background `#F8FAFC`, border-top `1px solid #E2E8F0`, padding `space-md`.

### Form Inputs & Selectors
- **Text Inputs**: Height 36px, background `#FFFFFF`, border `1px solid #E2E8F0`, radius 4px, padding `0 12px`, font `body-md` (`#0F172A`). Placeholder text `#94A3B8`. Focus state introduces a 1px border `#0D5C75` and a 1px outline in `#0D5C75`.
- **Input Error State**: Border `#B91C1C`, helper caption `label-sm` in `#B91C1C`.

### Checkboxes & Radio Controls
- **Checkboxes**: 16x16px square with 3px border radius, 1px border `#CBD5E1`, background `#FFFFFF`. Selected state background `#0D5C75` with white checkmark glyph.
- **Radio Buttons**: 16x16px circle, 1px border `#CBD5E1`. Selected state features an inner 6px filled circle in `#0D5C75`.

### Data Tables & Ledger Rows
- **Header Cells**: Height 36px, background `#F8FAFC`, border-bottom `1px solid #E2E8F0`, text `label-xs` uppercase tracking in `#475569`.
- **Data Rows**: Height 44px, background `#FFFFFF`, border-bottom `1px solid #E2E8F0`, text `body-md` (`#0F172A`), numbers aligned right with `font-feature-settings: "tnum"`. Row hover state `#F8FAFC`.
- **Total Rows**: Height 48px, background `#FFFFFF`, border-top `2px solid #0F172A`, text `headline-sm` bold.