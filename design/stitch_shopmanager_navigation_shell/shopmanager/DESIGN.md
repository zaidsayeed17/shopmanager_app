---
name: ShopManager
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
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-xl:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
  code-data:
    fontFamily: JetBrains Mono
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
  gutter-lg: 1.5rem
  margin: 1rem
  margin-md: 1.5rem
  margin-lg: 2rem
  space-xxs: 0.125rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
  space-2xl: 2rem
---

## Brand & Style
The design system prioritizes operational clarity, industrial durability, and immediate utility for small manufacturing and trading shop environments. Built for workshop-floor tablets, warehouse packing stations, and counter-top point-of-sale terminals, the interface resolves readability challenges posed by harsh daylight, dusty environments, and fast-paced physical handling.

The design movement combines **Corporate Modernism** with an **Industrial High-Contrast Utility** ethos:
- **Tone:** Methodical, unyielding, reliable, and functional.
- **Visual Weight:** Solid, anchored containers with decisive borders instead of ambiguous depth or heavy drop shadows.
- **Interaction Model:** Tactile, dense, and fast. Form inputs, data cells, and primary action triggers provide definite optical boundaries to minimize misclicks during high-stress order fulfillment and inventory tracking.

## Colors
The palette leverages a deep maritime slate teal as the primary authority color, supported by an industrial verdigris teal and functional workshop alerts.

### Palette Architecture
- **Primary (`#0D5C75`):** Deep Slate Teal. Anchors the primary controls, key actionable surfaces, active table selections, and prominent brand anchors.
- **Secondary (`#0F766E`):** Industrial Ocean Teal. Used for secondary active states, high-priority interactive icons, focus halos, and progressive disclosure toggles.
- **Tertiary (`#B45309`):** Safety Amber/Ochre. Dedicated strictly to operational warnings, pending states, stock shortages, and alerts requiring supervisor sign-off.
- **Neutral Surface Palette:**
  - Base Background: `#F8FAFC` (Slate 50) for reduced glare under workshop tube lighting.
  - Surface Containers: `#FFFFFF` (Pure White) for distinct containment cards and data tables.
  - Borders & Dividers: `#CBD5E1` (Slate 300) for interior lines, stepped down to `#E2E8F0` (Slate 200) for passive card bounds.
  - Text Hierarchy: Primary text at `#0F172A` (Slate 900) ensures a contrast ratio exceeding 12:1 against pure white; secondary text sits firmly at `#475569` (Slate 600) to preserve legibility under direct sunlight.

### Functional Status Accents
- **Success / In-Stock / Fulfilled:** `#15803D` (Forest Green) with `#DCFCE7` background fill.
- **Warning / Low Stock / Inspection Needed:** `#B45309` with `#FEF3C7` background fill.
- **Critical / Machine Down / Defect:** `#B91C1C` with `#FEE2E2` background fill.
- **Info / Staged / Processing:** `#0369A1` with `#E0F2FE` background fill.

## Typography
Type hierarchy is engineered to prioritize instant scannability and high optical weight. Regular weights (400) are reserved strictly for secondary meta captions, with all primary body copy set at Medium (500) and headings at Semi-Bold or Bold (600/700).

- **Tabular Figures:** Numbers across all production runs, order quantities, inventory SKUs, and monetary values must always display with monospaced tabular figures (`tnum`) enabled.
- **SKUs and Machine Codes:** Use `code-data` with `JetBrains Mono` for alphanumeric batch numbers, barcodes, and serial stamps to avoid confusion between ambiguous glyphs like `0` and `O` or `1`, `l`, and `I`.
- **Label Capitalization:** `label-sm` is reserved for all-caps table column headers, status tags, and machine telemetry metrics, requiring a minimum `0.04em` tracking for crisp outline definition.

## Layout & Spacing
The layout model employs a responsive, column-structured fluid-fill grid with deliberate compact density options suited for data-dense manufacturing workflows.

### Grid & Breakpoints
- **Desktop (1200px+):** 12-column layout, `margin-lg` (32px), `gutter-lg` (24px). Sidebar navigation remains anchored at a fixed 260px width.
- **Tablet / Rugged Terminal (768px - 1199px):** 8-column layout, `margin-md` (24px), `gutter` (16px). Sidebar collapses to a 64px icon-rail to prioritize operational work orders.
- **Mobile Handheld (360px - 767px):** 4-column layout, `margin` (16px), `gutter` (16px). Stacks table views into dense, line-delimited list cards.

### Spacing Philosophy
Compact density (`space-xs` to `space-md`) is applied to transactional table rows, machine dashboards, and batch-picking lists to limit unnecessary vertical scrolling. Expanded padding (`space-lg` to `space-xl`) is reserved strictly for high-touch form blocks, customer invoicing summaries, and modal dialogues.

## Elevation & Depth
Elevation is maintained primarily through structured borders and tonal containment rather than diffuse blur, avoiding visual ambiguity under high-glare environments.

### Stacking Structure
- **Level 0 (Canvas Base):** Surface color `#F8FAFC`. Un-elevated.
- **Level 1 (Card & Module Surfaces):** Surface `#FFFFFF`, enclosed with a continuous 1px border of `#E2E8F0`. Shadow: `0 1px 2px rgba(15, 23, 42, 0.05)`.
- **Level 2 (Dropdowns, Popovers, Active Drawers):** Surface `#FFFFFF`, border 1px `#CBD5E1`. Shadow: `0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.04)`.
- **Level 3 (Modal Confirmation Panels, Blocking Alerts):** Surface `#FFFFFF`, border 1px `#94A3B8`. Shadow: `0 10px 15px -3px rgba(15, 23, 42, 0.12), 0 4px 6px -4px rgba(15, 23, 42, 0.06)`. Backdropped by an overlay of `rgba(15, 23, 42, 0.45)`.

### Border Discipline
All actionable boundaries (tables, search boxes, card panels) rely on high-contrast stroke dividers. Never use pure drop-shadow to separate structural regions; a solid 1px `#E2E8F0` or `#CBD5E1` rule is mandatory.

## Shapes
A disciplined **Soft** (`1`) shape system enforces an engineered, machine-tool precision aesthetic.

- **Base Radius (4px / 0.25rem):** Form inputs, buttons, table cell badges, dropdown items, and card modules. Gives a crisp, clean-cut structural edge.
- **Large Radius (8px / 0.5rem):** Modals, flyout sheets, and root dashboard viewports.
- **Pill Radius (9999px):** Dedicated solely to navigation indicators, inline status chips (e.g., "In Stock", "Shipped"), and counter badges. The pill shape provides a distinct semantic cue that differentiates meta labels and active filters from interactive rectangular buttons.

## Components

### Buttons
- **Primary:** Solid `#0D5C75` fill, white `#FFFFFF` text, 4px border radius. Hover: `#0A475A`. Active: `#073543`. Focus ring: 2px solid `#0F766E` offset by 2px. Minimum height: 40px (desktop), 48px (mobile/tablet pick-and-pack mode).
- **Secondary:** Surface `#FFFFFF`, text `#0D5C75`, 1px solid `#CBD5E1`. Hover: `#F1F5F9` background with `#0D5C75` border.
- **Destructive:** Solid `#B91C1C` fill, white text. Reserved strictly for canceling orders, deleting master items, or stopping active runs.

### Navigation Indicator Pills
- Segmented controls and sub-navigation rely on pill indicators (`roundedness: 9999px`).
- **Active Pill:** `#0D5C75` background with pure white text, accompanied by a bold font weight (`label-md`).
- **Inactive Pill:** Transparent background, `#475569` text. Hover: `#E2E8F0` background with `#0F172A` text.

### Chips & Status Badges
- Compact pill-shaped metadata badges.
- Always use a 2-tone structure: a 10%–15% tinted pastel fill with a high-contrast 100% saturation text color and matching subtle 1px stroke (e.g., Warning: Fill `#FEF3C7`, Text `#92400E`, Border `#FCD34D`).

### Form Input Fields
- White background (`#FFFFFF`), 1px solid `#CBD5E1` border, 4px border radius.
- Minimum tap height: 40px. Inner horizontal padding: 12px (`space-md`).
- Placeholder text: `#94A3B8`.
- Focus State: 1px solid `#0D5C75` with a 2px outer outline of `#0D5C75/20`.
- Validation: Red border `#DC2626` with red inline helper text beneath.

### Checkboxes & Radio Buttons
- Precision 18x18px targets with 1px solid `#94A3B8` borders.
- Active checked state: Solid `#0D5C75` fill with a white checkmark or center pip.
- Hover state: Accent ring expansion with `#0D5C75/10`.

### Cards & Data Panels
- Background `#FFFFFF`, border 1px solid `#E2E8F0`, 4px border radius.
- Headers are divided from body contents with an explicit 1px horizontal rule (`#E2E8F0`).
- Padding: 16px (`space-lg`) on mobile, 20px on desktop.

### Data Tables (Workhorse Component)
- **Header Row:** Background `#F8FAFC`, uppercase `label-sm` text `#475569`, bottom border 2px solid `#CBD5E1`.
- **Data Rows:** Background `#FFFFFF`, alternating zebra striping optional (`#F8FAFC/50`). Row height: 44px (standard), 52px (touch mode). Bottom border: 1px solid `#E2E8F0`.
- **Selected Row:** Background `#F0FDFA` (Teal 50) with an absolute 3px left border of `#0D5C75`.