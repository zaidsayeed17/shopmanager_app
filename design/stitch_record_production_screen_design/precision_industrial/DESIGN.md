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
  display:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.015em
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
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 22px
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
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  data-mono:
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
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-desktop: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style

This design system is engineered for small-to-medium precision manufacturing, job shops, CNC facilities, and industrial service environments. The visual language conveys competence, exactitude, durable utility, and focused clarity. It rejects decorative fluff, excessive soft radii, and dramatic atmospheric depth in favor of rigorous tabular density, crisp data delineation, and effortless legibility under shop-floor and back-office lighting.

The design movement is **Utilitarian Corporate / Industrial Minimalism**:
- **High Information Density**: Compact vertical metrics, clean tabular structures, and precise line separators that optimize screen real estate for work orders, BOMs (Bills of Materials), and job tracking.
- **Physical Instrument Metaphor**: Clean borders, deliberate tactile contrast, and purposeful semantic indicators that resemble high-end measurement software and industrial instrumentation.
- **Restraint Over Expression**: Color is strictly functional, reserving high saturation exclusively for production statuses, tolerances, inventory thresholds, and critical machine alerts.

## Colors

The palette balances deep slate oceanics with precise industrial status tokens, underpinned by cool architectural neutrals.

### Surface & Background Tokens
- **Canvas Base**: `#F8FAFC` (Slate 50) — Crisp, glare-reducing background.
- **Card / Panel Surface**: `#FFFFFF` (Pure White) — High-contrast container for dense data and forms.
- **Surface Muted / Well**: `#F1F5F9` (Slate 100) — Sub-tables, table headers, and disabled fields.
- **Border Default**: `#E2E8F0` (Slate 200) — Strict 1px delineations between records and inputs.
- **Border Strong**: `#CBD5E1` (Slate 300) — Active boundaries, hover states, and structural splitters.

### Brand Tokens
- **Primary (`#0D5C75`)**: Deep Slate Teal. Used for primary execution actions, active navigation, and dominant system anchors.
- **Secondary (`#0F766E`)**: Deep Cyan Teal. Used for auxiliary batch actions, secondary tabs, and system confirmations.

### Feedback & Status Tokens
- **Success (`#15803D`)**: Green. In-spec measurements, completed work orders, and healthy runtime.
- **Warning / Alert (`#B45309`)**: Deep Amber. Low material stock, approaching machine maintenance, and calibration warnings.
- **Critical / Danger (`#B91C1C`)**: Deep Crimson. Machine downtime, QC rejections, overdue jobs, and destructive actions.

### Typography & Content Tokens
- **Text Primary (`#0F172A`)**: Slate 900. Core metrics, active labels, table headers, and primary inputs.
- **Text Secondary (`#475569`)**: Slate 600. Secondary metadata, unit markers, timestamps, and contextual captions.
- **Text Disabled**: `#94A3B8` (Slate 400).

## Typography

Typography relies entirely on **Inter** to ensure maximum glyph clarity and screen rendering performance. Tabular figures (`tnum`) must be enforced across all quantitative data columns, part numbers, runtimes, tolerances, and pricing displays.

- **Headlines**: Set tightly with neutral slate coloring. Headings maintain low visual displacement so tables and job sheets remain visible above the fold.
- **Data & Tables**: The default operational size is `body-md` (14px) and `body-sm` (13px), calibrated for compact scannability.
- **Labels**: `label-sm` utilizes uppercase rendering with subtle letter-spacing (`0.04em`) for column indicators, field prompts, and machine state captions.

## Layout & Spacing

The layout is built around a dense, high-utility **fluid grid system** designed to adapt cleanly between shop-floor tablets, rugged laptops, and multi-monitor back-office workstations.

### Grid & Structure
- **Desktop (1200px and up)**: 12-column layout with 24px (`1.5rem`) gutters and 24px margins. Content spans full widths to facilitate multi-column data grids, master-detail panes, and split job queues.
- **Tablet / Rugged Terminal (768px – 1199px)**: 8-column layout with 16px (`1rem`) gutters and margins. Side panels collapse into drawer drawers to preserve table workspace.
- **Mobile (below 768px)**: 4-column layout with 16px margins; complex tables shift into card-based summary lists with single-tap inspect drawers.

### Spacing Rhythm
- Spacing follows a compact 4px baseline rhythm. Standard form spacing defaults to `space-md` (12px) between fields and `space-sm` (8px) between related label-input pairings, maintaining maximum vertical density for rapid data entry without visual crowding.

## Elevation & Depth

This design system favors **low-contrast outlines and structural flat planes** over elevated shadows. In an industrial management context, shadows create visual ambiguity around touch targets and table borders.

- **Base Layering**: The Canvas background (`#F8FAFC`) anchors elevated Cards and Data Tables (`#FFFFFF`) with a continuous `1px solid #E2E8F0` border.
- **Shadowless Hierarchy**: Elevation is communicated through border contrast and background tone differentiation rather than blur radiuses.
  - Default Container: `1px solid #E2E8F0` on white surface.
  - Hover / Focus Container: `1px solid #CBD5E1`.
  - Floating Overlays & Modals: When vertical detachment is strictly required for tooltips or modal sheets, use a surgical, sharp shadow: `0 4px 12px -2px rgba(15, 23, 42, 0.08), 0 1px 3px 0 rgba(15, 23, 42, 0.04)` combined with an explicit `1px solid #CBD5E1` boundary.
- **Interactive States**: Hover states darken borders and subtly shift surface fills (`#F8FAFC`) without shifting element dimensions or casting diffused depth.

## Shapes

The shape system employs an intentional dual-standard to reinforce functional distinction between interactive containers and status indicators:

- **Geometric Containers, Inputs, and Actions (4px Radius)**:
  - All cards, panels, inputs, dropdown menus, table rows, and interactive buttons strictly feature a micro **4px (`0.25rem`) border radius**. This delivers crisp visual discipline, aligns precisely with dense technical grids, and eliminates the visual waste associated with circular components.
- **Exceptions (Pill Badges & Counters)**:
  - Pure status indicators, count pills, and tags are the only components permitted a full pill radius (`9999px`). The pill shape acts as an instant cognitive flag denoting *non-interactive metadata* or *state indicators* (e.g., "In Production", "Hold", "Shipped").

## Components

### Buttons
- **Primary Button**: Solid `#0D5C75` background, `#FFFFFF` text, 4px border radius. Padding: 8px 16px (body-md, 500 weight). Hover: `#0A475B`. Active: `#073544`. Focus: 2px offset outline using `#0D5C75`.
- **Secondary Button**: `#FFFFFF` background, 1px solid `#E2E8F0`, `#0F172A` text. Hover: `#F1F5F9`, border `#CBD5E1`.
- **Destructive Button**: Solid `#B91C1C` background, `#FFFFFF` text, 4px border radius. Used strictly for irreversible shop operations (e.g., scrapping inventory, canceling jobs).
- **Compact Table Button**: 6px 10px padding with 13px label size for high-density action rows.

### Status Badges & Chips (Pill Badges)
- Built exclusively with full rounded edges (`border-radius: 9999px`), 2px 10px padding, and `label-sm` uppercase typography.
- **Success / Complete**: Background `#DCFCE7`, text `#15803D`, border `1px solid #BBF7D0`.
- **Warning / Queued**: Background `#FEF3C7`, text `#B45309`, border `1px solid #FDE68A`.
- **Critical / Rejected**: Background `#FEE2E2`, text `#B91C1C`, border `1px solid #FECACA`.
- **Neutral / Draft**: Background `#F1F5F9`, text `#475569`, border `1px solid #E2E8F0`.

### Input Fields & Selects
- Height: 36px (compact default) or 32px (tabular inline edit).
- Surface: `#FFFFFF` fill with `1px solid #CBD5E1` and 4px radius. Text: `#0F172A`.
- Focus State: 1px border `#0D5C75` with `0 0 0 1px #0D5C75` box-shadow; no soft glows.
- Label: Positioned above input using `label-md` in `#475569`. Required indicators marked with red asterisk (`#B91C1C`).
- Numeric/Tolerance Inputs: Right-aligned numerical entry paired with tabular font metrics and optional fixed unit suffixes (`mm`, `in`, `psi`, `hrs`).

### Data Tables (Workhorse Component)
- **Header**: Height 36px, background `#F8FAFC`, border-bottom `1px solid #CBD5E1`, typography `label-sm` uppercase text in `#475569`.
- **Row**: Height 40px (standard) or 32px (condensed view). Bottom border `1px solid #E2E8F0`. Hover background `#F8FAFC`.
- **Cell Padding**: 8px 12px. Numeric values set in `data-mono` tabular figures.

### Checkboxes & Radios
- Box size: 16px × 16px with 3px border radius for checkboxes and round for radios.
- Unchecked: `1px solid #CBD5E1` with `#FFFFFF` background.
- Checked: `#0D5C75` background with sharp white vector checkmark.

### Cards & Industrial Panels
- Surface: `#FFFFFF` background with `1px solid #E2E8F0` perimeter border and 4px border radius.
- Padding: `space-lg` (20px) for standard summary cards; `space-md` (12px) for production queue dashboards.
- Dividers within cards use continuous `1px solid #E2E8F0` without margins.