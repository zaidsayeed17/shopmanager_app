---
name: ShopManager Workshop Flow
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
    fontSize: 1.75rem
    fontWeight: '700'
    lineHeight: 2.25rem
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 1.375rem
    fontWeight: '600'
    lineHeight: 1.75rem
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Inter
    fontSize: 1.125rem
    fontWeight: '600'
    lineHeight: 1.5rem
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 1rem
    fontWeight: '400'
    lineHeight: 1.5rem
  body-md:
    fontFamily: Inter
    fontSize: 0.875rem
    fontWeight: '400'
    lineHeight: 1.25rem
  body-sm:
    fontFamily: Inter
    fontSize: 0.75rem
    fontWeight: '400'
    lineHeight: 1rem
  label-lg:
    fontFamily: Inter
    fontSize: 0.875rem
    fontWeight: '600'
    lineHeight: 1.25rem
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 0.75rem
    fontWeight: '600'
    lineHeight: 1rem
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 0.6875rem
    fontWeight: '600'
    lineHeight: 0.875rem
    letterSpacing: 0.04em
  data-mono:
    fontFamily: Inter
    fontSize: 0.8125rem
    fontWeight: '500'
    lineHeight: 1.125rem
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
  gutter-mobile: 0.75rem
  margin: 1.5rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system targets industrial execution, floor managers, and shop inventory controllers managing high-tempo material dispatches. The aesthetic is utilitarian, dense, and uncompromisingly operational—modeled after technical flight consoles and modern precision equipment rather than generic administrative software. 

Key principles:
- **Zero-Latency Readability**: Information is scanned under harsh fluorescent workshop lighting or outdoors on ruggedized touch tablets.
- **Structural Integrity**: The layout prioritizes clear perimeter lines, high data density, and defined boundaries over ambient decorations.
- **Physical Feedback Metaphor**: Actions emulate physical dispatch manifests, using distinct transactional visual states that ensure workers and managers never mistake a staged requisition for an issued dispatch.

## Colors

The palette leverages industrial slate blues and teals to reduce eye strain over extended shifts, paired with functional safety and status tokens.

- **Primary (`#0D5C75`)**: Deep Slate Teal. Anchor for main headers, active primary workflows, and definitive action triggers (e.g., "Confirm Material Issuance").
- **Secondary (`#0F766E`)**: Rich Teal. Applied to secondary actions, supporting toolbars, active batch indicators, and segmented filter states.
- **Canvas & Surface**: Background sits at `#F8FAFC` (Slate 50), while interactive panels, inventory logs, and cards rest on `#FFFFFF` with strict `#E2E8F0` (Slate 200) structural boundaries.
- **Text & Hierarchy**: Primary body and data values use `#0F172A` (Slate 900) for sharp readability. Secondary annotations, SKU specifications, and metadata use `#475569` (Slate 600).
- **Functional Semantics**:
  - **Success / Cleared**: `#15803D` text on `#DCFCE7` surface. Signifies verified stock availability, completed issuance, and validated operator badges.
  - **Warning / Staged / Low Stock**: `#B45309` text on `#FEF3C7` surface, accented with `#F59E0B`. Alerts floor managers to lot shortages or pending supervisor authorizations.
  - **Critical / Blocked / Over-Allocation**: `#B91C1C` text on `#FEE2E2` surface, accented with `#EF4444`. Direct hard stops: damaged material lots, safety lockouts, or unauthorized worker IDs.

## Typography

Typographic scale is optimized for high-density transactional screens where compact structure preserves vertical real estate.

- **Numerics and Codes**: Work orders, serial identifiers, lot allocations, and unit counts must use font-variant tabular figures (`font-variant-numeric: tabular-nums`) to maintain alignment across vertical data tables.
- **Labels & Microcopy**: Form field headers, column tags, and SKU status flags use uppercase micro-labels (`label-sm` or `label-md`) with subtle positive tracking for immediate legibility at a distance.
- **Hierarchy Rules**: Emphasize weights (`600`, `700`) rather than drastic jumps in font size to maintain a compact, unified vertical rhythm across all forms and dispatch tables.

## Layout & Spacing

The layout is built on a tight 4px base increment, prioritizing horizontal density and scannability.

- **Grid Strategy**: Fluid 12-column grid on desktop screens (1024px and above) with a fixed 1440px max-width wrapper. It collapses to a 6-column grid on tablets (768px - 1023px) and a single-column layout on handheld mobile terminals (< 768px).
- **Split-Screen Workflow**: On desktop, the primary screen uses a fixed 400px lateral panel for "Worker & Work Order Profile" while the remaining fluid columns contain the "Pick List & Material Staging Table".
- **Density Rules**: Internal form gaps adhere to compact spacing (`space-sm` for related input/label pairs, `space-md` for field groups). Dense tabular rows are constrained to 36px–40px heights to maximize the number of visible line items without scrolling.

## Elevation & Depth

This design system rejects deep drop shadows in favor of a crisp, boundary-first structural aesthetic.

- **Flat Precision**: Elevation is communicated primarily via crisp borders (`1px solid #E2E8F0`) and subtle tonal stepping between the `#F8FAFC` base application canvas and `#FFFFFF` work cards.
- **Overlay & Staging Tiers**:
  - **Resting Cards**: `0 0 0 1px #E2E8F0`, no box-shadow.
  - **Focused/Active Inputs & Selected Rows**: `0 0 0 1px #0D5C75, 0 1px 2px 0 rgba(15, 23, 42, 0.05)`.
  - **Flyouts, Dropdowns & Barcode Scanner Modals**: `0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.04)`, bordered by `1px solid #CBD5E1`.

## Shapes

The design system enforces strict geometry reflecting physical machinery and precision measuring tools:

- **Core Elements (Inputs, Buttons, Cards)**: Built exclusively with a `4px` radius (`roundedness: 1`). This provides just enough softening to prevent visual harshness while maintaining clean grid lines and maximum internal screen real estate.
- **Status Badges & Identifiers**: Configured as full pills (`rounded-full` / `9999px`) to create an immediate shape contrast against square-edged data tables, cards, and input fields.
- **Icons & Checkboxes**: Square boundaries with minimal `2px` corners to reinforce the mechanical, utilitarian character of the software.

## Components

### Buttons
- **Primary ("Issue Materials", "Confirm Dispatch")**: `#0D5C75` background, `#FFFFFF` text, 4px border radius. Height: 36px (compact) or 42px (touch). Focused state displays an outer ring: `2px solid #0F766E` with a 2px offset.
- **Secondary ("Stage Items", "Scan Barcode")**: `#FFFFFF` background, `1px solid #CBD5E1`, text `#0F172A`. Hover: `#F1F5F9`.
- **Destructive ("Void Allocation", "Reject Stock")**: `#FFFFFF` background, `1px solid #FCA5A5`, text `#B91C1C`. Hover: `#FEE2E2`.

### Status Chips (Pill Badges)
Always use pill geometry (`border-radius: 9999px`) with micro uppercase text (`label-sm`), featuring a centered 6px dot:
- **Available / Verified**: Background `#DCFCE7`, text `#15803D`, dot `#16A34A`.
- **Low Stock / Partially Staged**: Background `#FEF3C7`, text `#B45309`, dot `#F59E0B`.
- **Depleted / Blocked**: Background `#FEE2E2`, text `#B91C1C`, dot `#EF4444`.
- **Draft / In-Transit**: Background `#F1F5F9`, text `#475569`, dot `#94A3B8`.

### Input Fields & Barcode Handlers
- **Text & Quantity Inputs**: White container, `1px solid #CBD5E1`, 4px border-radius. Font size `0.875rem` (`body-md`), height 36px. Tabular numeric display for counts and decimals.
- **Barcode / QR Scanner Field**: Prominent high-contrast input featuring a dedicated scanner icon prefix and an amber or teal pulse border indicator during active hardware listen states.

### Checkboxes & Selection Controls
- **Checkboxes**: 16x16px boxes with `2px` rounded corners, bordered with `1px solid #94A3B8`. Checked state: background `#0D5C75` with a `#FFFFFF` checkmark.
- **Selection Tables**: Selected rows switch background to `#F0FDFA` (teal tint) and establish a left border of `3px solid #0D5C75`.

### Material Dispatch Cards & Manifest Tables
- **Cards**: Flat white surface, `1px solid #E2E8F0` border, 4px border radius. Padding set to `12px` (dense) or `16px`. Header area separated by a horizontal `1px solid #F1F5F9` divider.
- **Material Line Items**: Dense tabular format. Columns: SKU/Code, Item Name, Required Qty, Issued Qty, Stock Location (Bin/Aisle), and Verification Status. Hover states on rows use `#F8FAFC`.
- **Worker Allocation Block**: A high-utility metadata module showing Worker Photo/Badge ID, Assigned Machine/Station, Active Shift, and Safety Clearance Level in a locked 2-column key-value matrix.