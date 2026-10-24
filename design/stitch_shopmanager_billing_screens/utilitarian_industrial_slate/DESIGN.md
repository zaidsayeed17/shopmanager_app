---
name: Utilitarian Industrial Slate
colors:
  surface: '#f8f9ff'
  surface-dim: '#ccdbf3'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d5e3fc'
  on-surface: '#0d1c2e'
  on-surface-variant: '#40484c'
  inverse-surface: '#233144'
  inverse-on-surface: '#eaf1ff'
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
  background: '#f8f9ff'
  on-background: '#0d1c2e'
  surface-variant: '#d5e3fc'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
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
    letterSpacing: -0.005em
  title-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  title-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  body-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  body-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
  financial-display:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.02em
  financial-tabular:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
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
  gutter-desktop: 1.25rem
  margin: 1rem
  margin-desktop: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system is engineered for industrial manufacturing units, wholesale distributors, and trading enterprises requiring high-throughput data processing. The operational reality demands an ergonomic interface that eliminates visual noise, minimizes eye strain across 10-hour shifts, and facilitates error-free keyboard navigation.

The aesthetic philosophy centers on **Precision Utilitarianism**:
- **Operational Density**: Tight visual grouping and structured layouts prioritize metrics, tabular ledgers, batch statuses, and inventory counts over decorative whitespace.
- **Instrumental Pragmatism**: Elements mirror heavy machinery control consoles—clean lines, deterministic interactions, and structural clarity.
- **Immediate Legibility**: Crisp contrasts, monospaced numeric tabular data, and unambiguous state signifiers ensure operators can parse invoicing and production pipelines in split seconds.

## Colors

The palette establishes an authoritative, reliable environment suited for commerce and fabrication workflows.

### Primary & Brand Accents
- **Primary Deep Slate Teal (`#0D5C75`)**: The core brand anchor used for top-level headers, primary transactional CTAs, navigation focus states, and primary active controls.
- **Secondary Teal (`#0F766E`)**: Secondary interactive states, supporting button fills, step indicators, and active contextual filters.

### Functional & Semantic Feedback
- **Critical / Red (`#B91C1C`)**: Overdue invoices, system alerts, negative stock deltas, destructive actions, and `Unpaid` badge text. Paired with background `#FEE2E2`.
- **Warning / Amber (`#B45309`)**: Pending deliveries, threshold limits, credit holds, and `Partial` payment badge text. Paired with background `#FEF3C7`.
- **Success / Green (`#15803D`)**: Completed work orders, balanced ledgers, verified shipments, and `Paid` badge text. Paired with background `#DCFCE7`.

### Canvas & Structural Surfaces
- **Canvas Base (`#F8FAFC`)**: A cool, low-strain neutral canvas backing the entire dashboard.
- **Surface Elevation (`#FFFFFF`)**: Pure white data containers, modal sheets, and card planes framed by a strict 1px border of `#E2E8F0`.
- **Text Primary (`#0F172A`)**: High-contrast slate-black for line items, financial totals, column headings, and critical metrics.
- **Text Secondary (`#475569`)**: Mid-tone slate for supporting metadata, field labels, audit timestamps, and table column descriptors.
- **Border Subtle (`#E2E8F0`)**: Structured grid delimiters, container outlines, and row dividers.

## Typography

The type system is built on **Inter**, configured for hyper-legibility in tabular layouts and data grids.

### Financial & Tabular Numbers
- All currency readouts, quantity columns, SKU codes, and ledger rows must enforce tabular figures (`font-variant-numeric: tabular-nums lining-nums`).
- **Indian Rupee (₹) Formatting**: Use the standard Indian numbering system (`₹12,34,567.00`). The rupee symbol (`₹`) is rendered in medium or regular weight adjacent to semibold or bold integers to maintain metric balance without visual heaviness.
- Micro-labels for column definitions and status indicators utilize `label-sm` with slight positive tracking (`0.03em`) and uppercase transformation to delineate field headers from data rows.

## Layout & Spacing

A compact, fluid layout system accommodates dense inventory sheets, dual-pane master-detail views, and split-screen invoicing.

### Grid Rhythm & Viewports
- **Desktop (≥1280px)**: 12-column fluid grid, `1.25rem` (20px) gutters, `1.5rem` (24px) screen margin. Designed for widescreen trading desks with persistent side navigation and split panel workflows.
- **Tablet (768px - 1279px)**: 8-column layout, `1rem` (16px) gutters, `1rem` (16px) margins. Non-essential table columns collapse into expandable detail drawers.
- **Mobile (<768px)**: 4-column layout, `0.75rem` (12px) gutters, `1rem` (16px) margins. Data tables stack into structured key-value summary cards.

### Density Rules
- High data density is maintained using `space-xs` (4px) and `space-sm` (8px) for internal form groups and compact table cells.
- Padding inside regular grid rows is capped at `0.5rem` (8px) vertically and `0.75rem` (12px) horizontally to maximize vertical row counts within the viewport.

## Elevation & Depth

To preserve sharp contrast and clarity under warehouse and office lighting, the design system minimizes deep blur shadows in favor of **Crisp Low-Contrast Outlines** and subtle boundary definitions.

- **Level 0 (Base Canvas)**: Background `#F8FAFC`.
- **Level 1 (Cards, Data Tables, Panels)**: Surface `#FFFFFF`, zero elevation, framed by a continuous `1px solid #E2E8F0` border.
- **Level 2 (Popovers, Filter Menus, Autocomplete Dropdowns)**: Surface `#FFFFFF`, border `1px solid #CBD5E1`, with a direct micro-shadow: `0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.04)`.
- **Level 3 (Modals, Process Dialogs)**: Surface `#FFFFFF`, border `1px solid #94A3B8`, shadow: `0 10px 15px -3px rgba(15, 23, 42, 0.12), 0 4px 6px -4px rgba(15, 23, 42, 0.04)`. Accompanied by a dimming scrim of `#0F172A` at 45% opacity.

## Shapes

The interface embraces a structured, architectural visual language:
- **Baseline Components (4px / 0.25rem)**: All buttons, text fields, search boxes, dropdown triggers, and card containers utilize a strict `4px` corner radius. This conveys stability and compact modularity.
- **Pill Badges (9999px)**: Status badges (Paid, Partial, Unpaid, In-Production) deviate intentionally from the 4px baseline by adopting a fully rounded pill shape. This distinct geometry ensures instant cognitive separation between actionable form inputs and static semantic status tags.

## Components

### Buttons
- **Primary**: Background `#0D5C75`, text `#FFFFFF`, border `1px solid transparent`, border-radius `4px`. Height: `32px` (compact) or `36px` (standard). Padding: `0 12px`. Hover: `#0A475B`. Active: `#083747`. Focus: 2px ring `#0D5C75` with 2px offset.
- **Secondary**: Background `#FFFFFF`, text `#0F172A`, border `1px solid #CBD5E1`, border-radius `4px`. Hover: `#F1F5F9`. Active: `#E2E8F0`.
- **Destructive**: Background `#FFFFFF`, text `#B91C1C`, border `1px solid #FCA5A5`, border-radius `4px`. Hover: `#FEE2E2`.

### Status Badges (Pills)
Constructed with full pill radius (`border-radius: 9999px`), padding `2px 8px`, `font-size: 11px`, `font-weight: 600`, line-height `14px`:
- **Paid**: Background `#DCFCE7`, text `#15803D`, border `1px solid #BBF7D0`.
- **Partial**: Background `#FEF3C7`, text `#B45309`, border `1px solid #FDE68A`.
- **Unpaid**: Background `#FEE2E2`, text `#B91C1C`, border `1px solid #FECACA`.

### Form Inputs & Search Fields
- Height `32px` for high-density entry; height `36px` for primary forms.
- Background `#FFFFFF`, border `1px solid #CBD5E1`, border-radius `4px`, padding `0 10px`.
- Text color `#0F172A`, placeholder `#94A3B8`.
- Focus: border `#0D5C75`, box-shadow `0 0 0 1px #0D5C75`.
- Error state: border `#B91C1C`, box-shadow `0 0 0 1px #B91C1C`.

### Cards & Data Panels
- Background `#FFFFFF`, border `1px solid #E2E8F0`, border-radius `4px`, padding `12px` or `16px`.
- Card Header: Separated by a bottom border `1px solid #F1F5F9` with compact vertical padding (`8px 0`).

### High-Density Data Tables
- Header Row: Background `#F8FAFC`, bottom border `1px solid #CBD5E1`. Typography: `label-sm`, color `#475569`.
- Body Row: Height `36px` (compact) or `44px` (regular). Border bottom `1px solid #E2E8F0`. Hover state: `#F1F5F9`.
- Numeric Cells: Aligned right, rendered in `financial-tabular` with `tabular-nums`.

### Checkboxes & Radios
- Size `16px x 16px`, border `1px solid #94A3B8`, border-radius `3px` (checkbox) or `50%` (radio).
- Checked: Background `#0D5C75`, border-color `#0D5C75`, checkmark `#FFFFFF`. Focus ring: 2px offset with `#0D5C75`.

### Financial Metric Displays
- KPI blocks feature secondary title uppercase (`label-sm`, `#475569`), followed by primary numeric figure in `financial-display` (`#0F172A`).
- Sub-text highlights comparison or payment delta tagged with corresponding positive (`#15803D`) or critical (`#B91C1C`) indicators.