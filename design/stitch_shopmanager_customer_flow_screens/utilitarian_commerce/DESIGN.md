---
name: Utilitarian Commerce
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#40484c'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
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
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
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
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
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
    fontSize: 10px
    fontWeight: '700'
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
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system targets small manufacturing unit owners, wholesale merchants, and retail trading proprietors. These users operate in high-friction, bright, and fast-paced environments (workshops, warehouse counters, loading docks) on mid-tier mobile hardware. The operational tone is pragmatic, unambiguous, and dependable.

The visual style is **High-Contrast Utilitarian**:
- Visual clarity precedes decoration. Information density is calibrated for rapid ledger scanning, quick bill generation, and fast inventory adjustments.
- Color communicates fiscal status instantly: black-and-white baseline execution accented by rich industrial teals, distinct amber warnings for receivables, and clear green/red status states.
- Structural elements favor tight, low-radius containers that maximize usable display area on small screens while maintaining strict structural separation via crisp hairline borders.

## Colors

The palette emphasizes immediate financial comprehension and operational safety:

- **Primary (`#0D5C75`)**: Used for top app bars, primary actions, key active states, and focal metrics.
- **Secondary (`#0F766E`)**: Used for secondary actions, interactive table links, and related transactional workflows.
- **Warning / Amber (`#B45309`)**: High-visibility balance indicators, pending credit terms, and low stock thresholds.
- **Critical / Red (`#B91C1C`)**: Overdue invoices, payment defaults, and validation block errors.
- **Success / Green (`#15803D`)**: Fully settled accounts (`₹0` balance), paid vouchers, and positive inventory shifts.
- **Surfaces & Borders**: Base canvas is `#F8FAFC`, card surfaces are strictly `#FFFFFF`, and structural borders/dividers use a consistent hairline `#E2E8F0`.
- **Text**: `#0F172A` delivers uncompromising legibility against white backdrops, supported by `#475569` for unit types, invoice metadata, and timestamps.

## Typography

The typography system relies solely on **Inter** to ensure maximum digital rendering clarity, clean numerical tabular alignment, and zero optical distortion on budget IPS displays.

### Formatting Rules:
- **Currency (`₹`)**: Always display values with the rupee glyph followed directly by tabular numbers using standard Indian grouping syntax (e.g., `₹12,45,670.00`). Use `fontWeight: 600` or `700` for monetary ledgers to ensure immediate visual weight.
- **Labels vs Body**: Labels are strictly semibold or bold to prevent ambiguity in dense, multi-field tally entry rows.
- **Hierarchy Reduction**: On mobile screens, title sizes scale downward immediately using `headline-lg-mobile` to preserve vertical screen space above the virtual keyboard.

## Layout & Spacing

A compact 4px base-unit spacing rhythm maintains high density without cognitive clutter.

- **Mobile (< 768px)**: 4-column layout with fixed 16px (`1rem`) outer margins and 16px (`1rem`) gutters. Vertical rhythm is locked tightly at 8px (`0.5rem`) and 12px (`0.75rem`) intervals between list entries and ledger groups.
- **Tablet / Desktop (≥ 768px)**: 8-column to 12-column layout with 24px (`1.5rem`) outer margin and 16px (`1rem`) gutters. Ledger detail views split into side-by-side inspection panes (left: bill list, right: active bill preview).
- **Safe Area Insets**: Layouts strictly account for the persistent 56px top app bar and the 64px bottom navigation bar with safe-area padding at viewport boundaries.

## Elevation & Depth

This system intentionally departs from diffused ambient shadows in favor of **Crisp Structural Hairlines (Low-contrast Outlines)**:

- **Default State**: Surface components (cards, tables, summary boxes) sit on `#F8FAFC` background with a `#FFFFFF` fill and a uniform `1px solid #E2E8F0` border. Shadows are completely omitted from standard rows and cards to eliminate GPU composite latency on low-end mobile devices.
- **Raised Elements (FABs, Toasts, Sticky Footers)**: Uses a tight, functional drop shadow to establish touch priority: `0px 2px 6px rgba(15, 23, 42, 0.12)`.
- **Modals & Bottom Action Sheets**: Framed with a 1px solid border at `#E2E8F0`, accompanied by a dark scrim overlay (`#0F172A` at 40% opacity) and an upward shadow: `0px -4px 16px rgba(15, 23, 42, 0.08)`.

## Shapes

The shape hierarchy serves functional categorization:

- **Workhorse Components (`4px`)**: Text inputs, standard action buttons, table cell containers, line-item cards, and summary stats use a crisp 4px radius. This keeps visual bounding boxes tight and predictable.
- **Overlays (`8px`)**: Bottom sheet containers, confirmation modals, and contextual menus use an 8px radius on top corners (sheets) or all corners (modals) to visually distinguish temporary system overlays from base canvas records.
- **Pill Shape (`9999px`)**: Reserved exclusively for operational status badges (e.g., "Paid", "Pending", "Partially Delivered"), count indicators, and bottom navigation icon active capsules.

## Components

### Buttons
- **Primary**: Background `#0D5C75`, text `#FFFFFF`, border-radius 4px, height 44px (touch target minimum), font `label-lg`. Active/pressed state dims to `#094457`.
- **Secondary**: Background transparent, border `1px solid #0D5C75`, text `#0D5C75`, border-radius 4px.
- **Destructive**: Background `#B91C1C`, text `#FFFFFF`, border-radius 4px.
- **FAB (Mobile only)**: Background `#0D5C75`, text `#FFFFFF`, 56×56px, circular (border-radius 9999px), icon size 24px, fixed at bottom-right 16px above the navigation bar. On tablet/desktop, transforms into a top-right standard 40px primary button labeled with text and icon.

### Form Inputs & Text Fields
- **Container**: Explicit `label-md` `#0F172A` above the input, with a red asterisk (`#B91C1C`) for mandatory parameters.
- **Field Box**: Background `#FFFFFF`, border `1px solid #E2E8F0`, 4px radius, height 44px, padding horizontal 12px.
- **States**: Focus state triggers `border-color: #0D5C75` with `outline: 1px solid #0D5C75`. Validation errors replace border with `#B91C1C` and append a `body-sm` error message immediately underneath.
- **Helper Text**: Placed below the field in `body-sm` `#475569`.

### Status Badges & Chips
- **Geometry**: Height 22px, border-radius 9999px, padding 2px 10px, typography `label-sm`.
- **Settled / Paid**: Background `#DCFCE7`, text `#15803D`.
- **Pending / Balance**: Background `#FEF3C7`, text `#B45309`.
- **Overdue / Alert**: Background `#FEE2E2`, text `#B91C1C`.
- **Draft / Muted**: Background `#F1F5F9`, text `#475569`.

### Cards & Record Lists
- **Structure**: Surface `#FFFFFF`, 1px solid `#E2E8F0`, 4px radius, padding 12px.
- **List Items**: Border-bottom `1px solid #E2E8F0`. High-density line items feature party/item name in `headline-sm` left-aligned, alongside balance or total right-aligned in `label-lg` with dynamic status tinting.
- **Hover/Tap State**: Background shifts to `#F8FAFC`.

### Navigation Bars
- **Top App Bar**: Height 56px, background `#0D5C75`, content text/icons `#FFFFFF`. Contains active module title and contextual action icons (Search, Filter, Export).
- **Bottom Navigation Bar**: Height 64px, surface `#FFFFFF`, top border `1px solid #E2E8F0`. Divided into 5 slots: **Home**, **Bills**, **Customers**, **Inventory**, **More**. Inactive items use `#475569`; active items render with an icon capsule in `#0D5C75` with matching active label.