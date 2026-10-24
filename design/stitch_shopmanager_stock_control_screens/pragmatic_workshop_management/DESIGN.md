---
name: Pragmatic Workshop Management
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
  tertiary: '#322a9e'
  on-tertiary: '#ffffff'
  tertiary-container: '#4a45b6'
  on-tertiary-container: '#c7c5ff'
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
  tertiary-fixed: '#e2dfff'
  tertiary-fixed-dim: '#c3c0ff'
  on-tertiary-fixed: '#0f0069'
  on-tertiary-fixed-variant: '#3b35a7'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
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
    letterSpacing: -0.01em
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
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
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
    letterSpacing: 0.03em
  number-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  number-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
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
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system is engineered specifically for small manufacturing hubs, assembly units, and trading workshops. The target audience comprises shop managers, inventory foremen, and owner-operators who prioritize operational throughput, dense data clarity, and unyielding reliability over decorative flair. 

The aesthetic is grounded in **Pragmatic Utility & Industrial Minimalism**. It balances high-density information architecture with sharp, dependable visual cues. Interfaces avoid distracting trends, prioritizing immediate scanning of inventory counts, material statuses, and financial figures under diverse lighting conditions (from fluorescent shop-floor lighting to direct sunlight on delivery docks). The design communicates stability, order, precision, and functional durability.

## Colors

The palette leverages a structured slate-teal foundation paired with high-clarity status signifiers designed for rapid cognitive processing.

### Palette Tokens
- **Primary (`#0D5C75`)**: Deep slate teal. Used for dominant operational CTAs, app header bars, active navigation selections, and structural focus elements.
- **Secondary (`#0F766E`)**: Teal accent. Used for secondary active states, key inventory indicators, and raw material accents.
- **Tertiary (`#3730A3`)**: Deep indigo. Reserved for finished product categorization and value-add tracking.
- **Neutral Primary (`#0F172A`)**: Slate 900. Applied to critical data values, headers, and standard tabular figures.
- **Neutral Secondary (`#475569`)**: Slate 600. Applied to secondary labels, unit descriptors, and metadata.
- **Canvas / Background (`#F8FAFC`)**: Slate 50. Soft, low-strain neutral base for entire views.
- **Card Surface (`#FFFFFF`)**: Pure white base for all data containers, tables, and inspection panes, anchored with a 1px `#E2E8F0` border.

### Functional Status Tokens
- **Success (`#15803D`)**: Green. Strictly for "In Stock", "Completed", and positive variance. Background tint: `#DCFCE7`.
- **Warning / Amber (`#B45309`)**: Deep Amber. Strictly for "Low Stock", "Pending Transfer", and maintenance due. Background tint: `#FEF3C7`.
- **Critical / Red (`#B91C1C`)**: Crimson. Strictly for "Out of Stock", "Halted", and scrap alerts. Background tint: `#FEE2E2`.
- **Inactive / Neutral (`#64748B`)**: Slate 500. Applied to archived, deprecated, or offline SKUs. Background tint: `#F1F5F9`.

## Typography

The typography uses **Inter** across all application surfaces. To ensure error-free shop operations, numerical data (quantities, batch IDs, SKU numbers, currency calculations) must strictly apply tabular numerals via `font-feature-settings: "tnum" 1, "cv05" 1`. 

Text hierarchy prioritizes high scannability:
- Use `headline-lg` and `headline-lg-mobile` exclusively for core screen roots and major inventory totals.
- Use `headline-md` for card titles, section demarcations, and batch modal headers.
- Use `label-sm` with uppercase transformation for column metrics, inventory property keys, and table headers.
- Numbers (`number-lg`, `number-md`) are weighted heavier than adjacent labels to ensure fast comprehension during active manufacturing runs.

## Layout & Spacing

The layout operates on an uncompromising 4px/8px baseline grid designed to maximize structural density without sacrificing touch and scan ergonomics.

### Layout Model
- **Mobile (< 768px)**: Single column, fluid stack. Screen margins are locked to `margin` (`1rem`). Data lists span edge-to-edge with inset content separators.
- **Tablet (768px - 1024px)**: 8-column layout with `gutter` (`1rem`) and `margin-tablet` (`1.5rem`). Master-detail layouts split 35% list, 65% inspect pane.
- **Desktop (> 1024px)**: 12-column layout with `gutter-desktop` (`1.5rem`) and `margin-desktop` (`2rem`). Max container width locks at `1440px` to maintain optimal data row scanning.

### Spacing Application
- Component internal padding uses compact tokens: `space-sm` (`0.5rem`) vertically and `space-md` (`0.75rem`) horizontally for form controls and table cells.
- Structural separation between cards and inventory groups relies strictly on `space-md` and `space-lg`, avoiding excess whitespace that forces needless scrolling.

## Elevation & Depth

This design system avoids decorative blurred drop shadows, ambient glow, and skeuomorphic gradients. The physical shop floor environment demands immediate clarity and high peripheral visibility under glare.

### Architectural Hierarchy
- **Level 0 (Canvas Base)**: `#F8FAFC`. The foundational backdrop for all screens.
- **Level 1 (Cards, Modules & Tables)**: Pure `#FFFFFF` surface bounded by a flat, crisp `1px solid #E2E8F0` border. No drop shadows.
- **Level 2 (Popovers, Filter Menus & Dropdowns)**: Pure `#FFFFFF` surface with `1px solid #CBD5E1` and a functional, high-density contact drop: `box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.05)`.
- **Level 3 (Modal Overlays & Quick-Input Drawers)**: Deep slate semi-transparent mask (`rgba(15, 23, 42, 0.60)`) with a centered `#FFFFFF` container outlined in `1px solid #94A3B8`.

## Shapes

The design language uses a consistent, compact **4px corner radius (`roundedness: 1`)** across all interactive elements, structural cards, tables, inputs, and modals. This restrained geometric approach reinforces a machined, dependable tool aesthetic.

The sole explicit exception to the 4px rule is status badges and categorization tags, which use fully pill-shaped (`9999px`) boundaries to visually segregate operational states and metadata tags from interactive rectilineal controls.

## Components

### Top Application Bar
- **Structure**: A fixed 56px high bar (`#FFFFFF` or `#0D5C75`). Flat boundary with a `1px` bottom border (`#E2E8F0` or `#0A475A`).
- **Composition**: Contains exclusively a functional back arrow (`24x24px` hit target with an active touch area of `44x44px`), followed immediately by the current view/SKU title in `headline-sm` or `headline-md`. 
- **Constraint**: Strictly prohibits profile avatars, greeting banners, decorative icons, and notification bells. Operational focus remains absolute.

### Buttons
- **Primary Button**: Solid `#0D5C75` background, `#FFFFFF` text, `4px` radius. Height is 40px (desktop) or 44px (touch). Padding: `0 16px`. Active state shifts to `#0A475A`.
- **Secondary Button**: `#FFFFFF` background, `1px solid #CBD5E1` border, `#0F172A` text, `4px` radius. Hover/active shifts to `#F1F5F9`.
- **Critical Action Button**: Solid `#B91C1C` background, `#FFFFFF` text, `4px` radius. Used only for unrecoverable scrap, deletion, or stock write-offs.

### Badges (Status Indicators)
All status badges are rendered as compact pills (`border-radius: 9999px`) with padding `2px 8px` and font style `label-sm`:
- **In Stock**: Background `#DCFCE7`, text `#15803D`.
- **Low Stock**: Background `#FEF3C7`, text `#B45309`.
- **Out of Stock**: Background `#FEE2E2`, text `#B91C1C`.
- **Inactive / Archived**: Background `#F1F5F9`, text `#64748B`.

### Item Type Tags
Categorization pills distinguishing stock nature:
- **Raw Material**: Background `#CCFBF1`, text `#0F766E`, border `1px solid #99F6E4`.
- **Finished Product**: Background `#E0E7FF`, text `#3730A3`, border `1px solid #C7D2FE`.

### Input Fields & Selectors
- **Container**: White background, `1px solid #CBD5E1` border, `4px` radius, height 40px, padding `0 12px`.
- **Typography**: Text uses `body-md` (`#0F172A`). Placeholder uses `#94A3B8`.
- **State**: Focus applies a sharp `2px` ring: `outline: 2px solid #0D5C75; outline-offset: -1px;`.
- **Numerical Inputs**: Integrated increment/decrement steppers positioned on the right for touch-friendly stock counting.

### Checkboxes & Radio Controls
- **Geometry**: Checkboxes feature a `4px` radius (`18x18px`); radio controls are circular (`18x18px`).
- **Coloration**: Unchecked has a `1.5px solid #94A3B8` border on white. Checked is filled with `#0D5C75` with a crisp white checkmark.

### Cards & Data Panels
- **Structure**: Background `#FFFFFF`, border `1px solid #E2E8F0`, corner radius `4px`.
- **Header**: Divided by an optional sub-divider `1px solid #F1F5F9`, padding `12px 16px`.
- **Content Area**: Dense, zero-margin data tables or key-value metric clusters.

### Lists & Inventory Rows
- **Layout**: Minimum touch target of 48px per row. 
- **Separators**: Divided by `1px solid #F1F5F9`.
- **Content Layout**: Left-aligned primary label with SKU/Item-Type pill; right-aligned current stock quantity (`number-md`) anchored directly above the status badge.