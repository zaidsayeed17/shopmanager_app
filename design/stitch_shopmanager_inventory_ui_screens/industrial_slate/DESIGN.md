---
name: Industrial Slate
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
  tertiary: '#2d1bb7'
  on-tertiary: '#ffffff'
  tertiary-container: '#473cce'
  on-tertiary-container: '#c7c4ff'
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
  tertiary-fixed: '#e3dfff'
  tertiary-fixed-dim: '#c3c0ff'
  on-tertiary-fixed: '#100069'
  on-tertiary-fixed-variant: '#372abf'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  title-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
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
    fontWeight: '500'
    lineHeight: 20px
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
  currency-display:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 26px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.25rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system caters to small manufacturing and trading operations—specifically Indian MSMEs balancing raw material inwarding, production batches, multi-channel wholesale, and ledger accounts. The visual tone is grounded, utilitarian, and high-efficiency: built for shop-floor owners navigating quick entries on mobile under direct sunlight or processing batch updates on desktop terminals.

The aesthetic fuses **Corporate / Modern** precision with **Tactile Utility**:
- High-contrast structural boundaries prioritizing immediate data recognition over decorative flourish.
- Clear item categorization (Raw Materials vs. Finished Goods) built into visual workflows.
- Native handling of localized industrial patterns, such as the Indian Rupee (`₹`) symbol formatting, GST rate summaries, and metric unit labels (kg, mtr, pcs, roll).
- Visual noise is strictly minimized; interfaces favor rapid glanceability, low cognitive load, and zero latency in high-turnover inventory operations.

## Colors

The palette balances industrial permanence with unmistakable status semantics.

### Foundational Palette
- **Canvas / App Background**: `#F8FAFC` (Slate 50) provides a soft, glare-resistant work field.
- **Card / Surface**: `#FFFFFF` with structural `#E2E8F0` border strokes.
- **Primary (`#0D5C75`)**: Deep Slate Teal. Applied to top headers, key primary navigation triggers, and prominent action points.
- **Secondary (`#0F766E`)**: Rich Teal. Applied to secondary controls, sub-navigation, and raw inventory metadata.
- **Neutral Primary (`#0F172A`)**: Slate 900 for primary figures, ledger values, and SKU titles.
- **Neutral Secondary (`#475569`)**: Slate 600 for column headers, secondary timestamps, and unit specifiers.
- **Border & Dividers (`#E2E8F0`)**: Hard geometric boundaries delineating rows, cards, and input frames.

### Semantic Tones
- **Success / In-Stock / Cleared**: `#15803D` (Text/Stroke) paired with `#DCFCE7` (Background fill).
- **Warning / Low Stock / Pending**: `#B45309` (Text/Stroke) paired with `#FEF3C7` (Background fill).
- **Critical / Out of Stock / Overdue**: `#B91C1C` (Text/Stroke) paired with `#FEE2E2` (Background fill).

### Inventory Classification Badges
- **Raw Material**: `#0F766E` text seated on `#CCFBF1` surface.
- **Finished Product**: `#4338CA` text seated on `#EEF2FF` surface.

## Typography

Inter handles the complete range of operational data across dense tables and mobile checkout screens.
- **Tabular Numerals**: Apply `font-feature-settings: "tnum" 1` across all data tables, price fields, inventory counters, and SKU tags to keep digits aligned vertically.
- **Currency Symbols**: Prefix `₹` directly to amounts with matching weight and size (e.g., `₹1,45,200.00`).
- **Data Table Headers**: Render with `label-md` or `label-sm` in all-caps or structured sentence-case using `Text Secondary` (`#475569`).
- **Hierarchy Rules**: Primary identifiers (Party Names, Item Names) receive `title-md` or `title-sm` in `#0F172A`. Supporting descriptors (Batch IDs, HSN codes) drop to `body-sm` in `#475569`.

## Layout & Spacing

The layout is built for quick thumb-reach entry on phones and dense horizontal layouts on workshop floor tablets and counter PCs.

### Responsive Breakpoints
- **Mobile (< 768px)**: Single-column fluid view. Standardized `16px` (`margin`) outer screen margin. Bottom navigation bar with 4-5 core destinations (Stock, Inward, Outward, Ledger, More). Fixed top bar displaying the current warehouse/shop branch switch and global search.
- **Tablet / Counter POS (768px - 1024px)**: Collapsed or expanded 72px left-rail navigation with active indicators on the Stock module. Two-column layout pairing item lists with right-hand inspect panels.
- **Desktop (> 1024px)**: Standard 240px persistent sidebar navigation. Fluid multi-column data grids with dense inline row actions.

### Spacing Model
- Input fields and buttons use `8px` (`space-sm`) vertical padding and `12px` to `16px` (`space-md`) horizontal padding.
- Card containers use consistent `16px` (`space-md`) inner padding.
- Structural row items within ledger records maintain a tight `8px` (`space-sm`) vertical gap to ensure multiple line items fit within one viewport fold.

## Elevation & Depth

Visual separation relies on strict **low-contrast outlines** and tonal stacking rather than pronounced drop shadows.

- **Standard Cards**: Solid `#FFFFFF` surface bounded by a crisp `1px solid #E2E8F0`. Shadow is absent (`none`) in static rest states.
- **Hover / Interactive Cards**: `0 1px 3px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04)`. Low diffusion prevents glare fatigue.
- **Floating Modals / Bottom Sheets**: Grounded shadow of `0 10px 15px -3px rgba(15, 23, 42, 0.1), 0 4px 6px -4px rgba(15, 23, 42, 0.05)` coupled with a dimming backdrop overlay of `#0F172A` at 40% opacity.
- **Top App Bar & Bottom Nav**: Defined by a direct border line (`border-b` / `border-t` with `1px solid #E2E8F0`) over surface white, preserving edge definition across all screens.

## Shapes

The design uses a clean, strict **Soft (`roundedness: 1`)** standard across all structural components:
- **Buttons, Form Inputs, Textareas, and Cards**: Strictly `4px` corner radius (`rounded`). This geometric sharpness delivers an engineered, industrial tool feel.
- **Status Badges & Category Tags**: An intentional exception: these use fully rounded pill profiles (`border-radius: 9999px`) to create clear shape contrast between structural interface containers and data chips.
- **Modals & Drawers**: Mobile bottom sheets feature `4px` top corners (`rounded-t`), keeping the utility-first language consistent.

## Components

### Buttons
- **Primary**: Background `#0D5C75`, text `#FFFFFF`, border-radius `4px`, hover state `#0A475B`, active state `#083B4C`. Minimum tap height `44px` on mobile, `36px` on tablet/desktop.
- **Secondary**: Surface `#FFFFFF`, border `1px solid #E2E8F0`, text `#0F172A`. Hover: background `#F8FAFC`, border `#CBD5E1`.
- **Destructive**: Background `#B91C1C`, text `#FFFFFF`. Used for transaction cancellations or item deletion.

### Category Chips & Status Badges
- **Pill Badges**: Border-radius `9999px`, padding `2px 8px`, typography `label-sm`.
  - **Raw Material**: Background `#CCFBF1`, text `#0F766E`, border `1px solid #99F6E4`.
  - **Finished Product**: Background `#EEF2FF`, text `#4338CA`, border `1px solid #C7D2FE`.
  - **Low Stock**: Background `#FEF3C7`, text `#B45309`, border `1px solid #FDE68A`.
  - **Out of Stock**: Background `#FEE2E2`, text `#B91C1C`, border `1px solid #FECACA`.
  - **Available**: Background `#DCFCE7`, text `#15803D`, border `1px solid #BBF7D0`.

### Input Fields & Search Bars
- Bounded by a `1px solid #E2E8F0` border, `4px` radius, `#FFFFFF` background.
- Focus State: Border color `#0D5C75` with a subtle `0 0 0 1px #0D5C75` ring.
- Numeric / Rate Inputs: Fixed left-adornment with `₹` or suffix units (`kg`, `pcs`, `box`) in `#475569`.

### Inventory Cards & Ledger Rows
- **Card**: Surface `#FFFFFF`, border `1px solid #E2E8F0`, radius `4px`, padding `16px`.
- **List Row**: Bounded by a bottom border `1px solid #E2E8F0`, padding `12px 16px`. Left column houses Item Name and Category Pill; right column displays Current Quantity in `title-sm` and Total Value (`₹`) in `body-sm` secondary tone.

### Checkboxes & Radios
- Size `18px x 18px`, `4px` radius for checkboxes, circle for radios.
- Unchecked: `1.5px solid #CBD5E1`, background `#FFFFFF`.
- Checked: `#0D5C75` fill with pure white icon marks.

### Application Navigation
- **Top App Bar**: Background `#FFFFFF`, height `56px`, bottom border `1px solid #E2E8F0`. Displays current facility name (with a switch dropdown), quick barcode scanner icon, and search bar.
- **Mobile Bottom Nav**: Background `#FFFFFF`, height `64px`, border-top `1px solid #E2E8F0`. Items arranged with icon and `label-sm`. The active "Stock" tab renders in `#0D5C75` with a solid active icon; inactive tabs use `#475569`.
- **Tablet Left Rail**: 72px wide, border-right `1px solid #E2E8F0`, top logo container followed by vertical navigation icons with active indicator pill in `#0D5C75`.