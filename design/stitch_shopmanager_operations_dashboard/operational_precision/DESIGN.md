---
name: Operational Precision
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
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
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
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
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
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1.25rem
  space-xl: 2rem
---

## Brand & Style

This design system targets independent manufacturing workshops, fabricators, machine shops, and specialized trading businesses. The users are shop owners, production foremen, and dispatch operators who split their attention between production floors, desktop workstations, and mobile clipboards. 

The aesthetic is grounded in **Utilitarian Operationalism**: high-contrast, structured, dense, and pragmatic. It rejects decorative softness, gratuitous elevations, and low-contrast trends in favor of legible metrics, distinct status indicators, and immediate data comprehension. The interface projects confidence, durability, and systematic control, allowing operators to make quick production and fulfillment decisions without visual fatigue.

## Colors

The color palette is built for clarity and contrast under varied workshop lighting conditions.

- **Primary (`#0D5C75`)**: Deep Slate Teal used for top-level navigation headers, primary action triggers, key table row highlights, and active tabs.
- **Secondary (`#0F766E`)**: Teal accent for operational states, secondary batch processes, and active filter indicators.
- **Warning / Accent (`#B45309`)**: Deep Amber for inventory reorder alerts, machine maintenance notices, and pending invoices.
- **Success (`#15803D` dark, `#16A34A` bright)**: Distinct green tones for verified quality checks, received shipments, and completed jobs.
- **Critical / Error (`#DC2626`)**: Direct red for machine downtime, stock-outs, and critical order bottlenecks.
- **Neutral Primary (`#0F172A`)**: Near-black slate for maximum contrast body and headline typography.
- **Neutral Secondary (`#475569`)**: Medium slate for metadata, tabular column titles, SKU labels, and unit indicators.
- **Surfaces**: Canvas renders on `#F8FAFC`, with panel and card surfaces sitting flat on `#FFFFFF` bounded by strict `#E2E8F0` hairline dividers.

## Typography

The design system exclusively implements **Inter** across all typographic applications. Data-dense layouts require precise horizontal metrics, neutral letterforms, and high legibility at compact scales.

- Use tabular numbers (`font-variant-numeric: tabular-nums`) by default on all numerical figures, serial tags, timestamps, currencies, and part inventories.
- Uppercase styling is reserved strictly for `label-sm` when designating short status flags, units of measurement, or column headers (e.g., `QTY`, `SKU`, `NET WT`).
- Body text prioritizes `14px` (`body-md`) with `20px` line height for compact operational density without sacrificing scannability.

## Layout & Spacing

Layouts follow a structured fluid 12-column grid system for desktop and tablet screens, shifting to a 4-column system on mobile devices.

- **Breakpoints**: Mobile (`0–639px`), Tablet (`640–1023px`), Desktop (`1024px+`), Large Workstation (`1440px+`).
- **Canvas Margins**: `1rem` on mobile, scaling to `2rem` on desktop displays to maximize tabular width while containing content safely away from the window frame.
- **Rhythm**: Layout intervals follow a compact 4px base increment (`0.25rem`), prioritizing dense content structures over sprawling white space. Form controls and table row paddings align to `0.5rem` (`space-sm`) and `0.75rem` (`space-md`) vertical limits.

## Elevation & Depth

This design system avoids blurry layered drop shadows, ambient glow, or translucent materials. 

- **Primary Boundary**: Separation relies on structural, crisp `1px solid #E2E8F0` borders applied to cards, tables, modal containers, and inputs.
- **Overlay Hierarchy**: When dialogs, dropdowns, or slide-over drawer sheets appear, they use a single defined border combined with a tight, utility-focused shadow: `0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.06)`.
- **Canvas Stacking**: The background canvas sits flat at `#F8FAFC`. All primary operational areas—such as inventory lists, order detail cards, and manufacturing tickets—sit directly on `#FFFFFF` with uniform border definitions.

## Shapes

The interface implements a strict `4px` corner radius (`0.25rem`, Soft level `1`) for all functional boundaries, including cards, action buttons, table cell selections, input boxes, and modal panels. 

The sole exception to the 4px baseline is the **pill badge shape** (`border-radius: 9999px`), used exclusively for operational status tags, stage labels, and batch counts. This purposeful contrast ensures operators immediately distinguish state markers from clickable buttons or structural cards.

## Components

### Buttons
- **Primary**: Background `#0D5C75`, text `#FFFFFF`, border-radius `4px`, padding `8px 16px`. Active state shifts to `#0A4659`. Focus ring is `2px solid #0F766E` with `2px` offset.
- **Secondary**: Background `#FFFFFF`, text `#0D5C75`, border `1px solid #0D5C75`, border-radius `4px`, padding `8px 16px`. Hover switches background to `#F1F5F9`.
- **Destructive**: Background `#FFFFFF`, text `#DC2626`, border `1px solid #DC2626`, border-radius `4px`. Hover background tint `rgba(220, 38, 38, 0.06)`.

### Cards & Panels
- **Container**: Background `#FFFFFF`, border `1px solid #E2E8F0`, border-radius `4px`, shadow `none`. Padding ranges from `16px` (`space-md`) on mobile to `20px` (`space-lg`) on desktop.
- **Card Header**: Border-bottom `1px solid #E2E8F0`, padding-bottom `12px`, margin-bottom `16px`. Typography set to `headline-sm` with neutral primary `#0F172A`.

### Status Badges (Pills)
- **Shape**: Full pill radius (`border-radius: 9999px`), height `24px`, horizontal padding `10px`, font `label-sm`.
- **In Production / Transit**: Background `#F0FDFA`, text `#0F766E`, border `1px solid #99F6E4`.
- **Pending / Warning**: Background `#FFFBEB`, text `#B45309`, border `1px solid #FDE68A`.
- **Completed / Ready**: Background `#F0FDF4`, text `#15803D`, border `1px solid #BBF7D0`.
- **Blocked / Critical**: Background `#FEF2F2`, text `#DC2626`, border `1px solid #FECACA`.

### Form Fields & Inputs
- **Text & Number Inputs**: Background `#FFFFFF`, border `1px solid #E2E8F0`, border-radius `4px`, text `#0F172A`, height `38px`, padding `0 12px`, font `body-md`. Focus state uses border `1px solid #0D5C75` with a `1px` outline.
- **Labels**: Typography set to `label-md` in `#475569`, bottom margin `6px`.

### Selection Controls
- **Checkboxes & Radios**: Size `16px x 16px`, border `1px solid #CBD5E1`, border-radius `3px` (checkbox) or circular (radio). When checked: background `#0D5C75`, border-color `#0D5C75`, white checkmark or center pip.

### Data Tables & Work Orders
- **Header**: Background `#F8FAFC`, border-bottom `1px solid #E2E8F0`, typography `label-sm` uppercase in `#475569`.
- **Rows**: Background `#FFFFFF`, border-bottom `1px solid #E2E8F0`, text `#0F172A`, height `44px`. Hover background changes to `#F1F5F9`.
- **Numeric Cells**: Right-aligned, formatted with `font-variant-numeric: tabular-nums`.