# ShopManager — Complete User Manual & Owner's Guide

Welcome to **ShopManager**, your complete offline shop management system designed for retail, wholesale, manufacturing, and local production businesses.

This manual provides clear, step-by-step instructions for every feature, screen, and workflow in the application.

---

## Table of Contents
1. [Getting Started & Navigation](#1-getting-started--navigation)
2. [Dashboard & Daily Snapshot](#2-dashboard--daily-snapshot)
3. [Customer Management & Advance Ledger](#3-customer-management--advance-ledger)
4. [Stock & Inventory Management](#4-stock--inventory-management)
5. [Ready Stock Module (Colour Ledger)](#5-ready-stock-module-colour-ledger)
6. [Worker Management, Material Issuance & Production](#6-worker-management-material-issuance--production)
7. [Worker Wages & Cutting System](#7-worker-wages--cutting-system)
8. [Billing, GST & PDF Invoices](#8-billing-gst--pdf-invoices)
9. [Payments, Printing & WhatsApp Sharing](#9-payments-printing--whatsapp-sharing)
10. [Reports & Business Analytics](#10-reports--business-analytics)
11. [Data Safety: Backup, Restore & Excel Export](#11-data-safety-backup-restore--excel-export)
12. [Troubleshooting & Frequently Asked Questions](#12-troubleshooting--frequently-asked-questions)
13. [Quick Workflow Cheat Sheet](#13-quick-workflow-cheat-sheet)

---

## 1. Getting Started & Navigation

### Application Overview
ShopManager operates **100% offline**, storing all your business data safely on your local device. No active internet connection is required to create bills, manage stock, issue worker materials, or view reports.

### Layout & Navigation Bar
- **Mobile Devices**: Bottom navigation bar with 5 main tabs: **Dashboard**, **Customers**, **Billing**, **Stock**, **Workers**, **Reports**, and **Settings**.
- **Tablets & Desktop**: A left side rail providing quick access to all modules.

---

## 2. Dashboard & Daily Snapshot

The Dashboard is your command center, updating automatically in real time as transactions occur.

### Header & Day Opening
- **Greeting**: Shows time-appropriate greeting (*Good morning / afternoon / evening*) and today's full date.
- **Fresh Start Banner**: On a fresh install or after a reset, displays a "Welcome to ShopManager" banner until your first bill is created.

### Today's Snapshot Cards
1. **Today's Sales**: Total gross sales amount and bill count generated today.
2. **Payments Recd**: Total payment collections today with method breakdown (*e.g., ₹5,000 Cash • ₹3,200 UPI*).
3. **Outstanding**: Total customer dues across all active accounts with the number of pending customer accounts.
4. **Low Stock**: Count of inventory items at or below minimum reorder thresholds.

### Overview Cards
- **Stock Overview**: Quick count of raw materials, finished products, total inventory valuation in Rupees, and low-stock alerts.
- **Worker Status**: Active worker count, total material issuances pending return/production, and today's cutting summary.
- **Recent Bills**: List of the 5 most recently created bills with customer name, bill number, date, amount, and status pill (**Paid**, **Partial**, **Unpaid**, or **Voided**). Tap any bill to view details.

---

## 3. Customer Management & Advance Ledger

### Viewing the Customer List
1. Tap **Customers** from the navigation bar.
2. Search by **Customer Name**, **Mobile Number**, **Address**, or **GSTIN**.
3. Filter using chips: **All**, **Active**, **Inactive**, or **Dues Only**.
4. Sort by **Name (A-Z)**, **Highest Dues**, or **Recent**.
5. Each card displays:
   - **Red Amount**: Outstanding balance owed by customer.
   - **Teal/Blue Amount**: Advance deposit credit held for customer.
   - **Green Badge**: All clear (zero balance).

### Adding a New Customer
1. Tap **+ Add Customer** (or **+** FAB).
2. *(Optional)* Tap **Import from Contacts** at the top right to pick a phone contact. The app automatically fills the Name and 10-digit mobile number.
3. Fill in the fields:
   - **Customer Name** *(Required)*: Must be unique.
   - **Mobile Number** *(Required)*: 10-digit number. If a duplicate mobile exists, the app shows a warning dialog but allows saving if confirmed.
   - **Address** *(Optional)*: Shop or factory location.
   - **Opening Balance (₹)** *(Optional)*: Enter existing dues if migrating from paper books.
   - **GSTIN & Business Details** *(Optional)*: Tap to expand and enter GSTIN and Trade/Firm Name.
   - **Notes / Payment Terms** *(Optional)*: Preferred transport, credit period, etc.
4. Tap **Create Customer**.

### Editing a Customer Profile
1. Open the Customer Detail screen.
2. Tap the **Edit** (pencil) icon in the top app bar.
3. Update fields or toggle **Customer Account Status** to **Inactive** (hides customer from billing dropdowns without losing transaction history).
4. Tap **Save Changes**.

### Customer Detail & Account Balance
The Customer Detail screen features an **Account Balance Card**:
- **Outstanding Balance**: Total unpaid dues.
- **Advance Held**: Advance deposit balance available to apply to future bills.
- **Total Billed vs Total Paid**: Cumulative totals for the customer.

#### Recording an Advance / Deposit
1. Tap **Record Advance** on the Customer Detail screen.
2. Enter **Deposit Amount (₹)**.
3. Select **Payment Method** (*Cash*, *UPI*, or *Other*).
4. Select **Date** and enter optional **Notes**.
5. Tap **Save Advance**.
6. The advance is credited to the customer's account and can be applied during billing.

#### Viewing Customer Tabs
- **Ledger Tab**: Complete running balance ledger with Debit (+), Credit (-), Date, and Running Balance.
  - Tap **Statement (PDF)** to generate and print/share a Customer Ledger PDF statement.
  - Tap **Load Previous Transactions** to view older ledger history.
- **Bills Tab**: Full list of bills generated for this customer with payment status.
- **Payments Tab**: Full list of payments and advance deposits recorded for this customer.

---

## 4. Stock & Inventory Management

### Viewing Stock & Inventory
1. Tap **Stock** from the navigation bar.
2. Search by item name or category.
3. Filter by category tabs: **All**, **Raw Materials**, or **Finished Products**.
4. Tap **Low Stock Alerts** chip to highlight items below minimum levels.
5. Sort by **Name (A-Z)** or **Quantity**.

### Adding a New Stock Item
1. Tap **+ Add Item** (or **+** FAB).
2. Select **Item Type**: **Raw Material** or **Finished Product**.
3. Fill in details:
   - **Item Name** *(Required)*: Must be unique.
   - **Category** *(Optional)*: e.g., Hardware, Fabric, Electrical.
   - **Unit of Measurement** *(Required)*: Select a chip (*kg, pcs, meters, rolls, spools, box*) or type custom unit.
   - **Opening Quantity** *(New items only)*: Current stock quantity on hand.
   - **Purchase Rate (₹)**: Cost price per unit.
   - **Selling Rate (₹)**: Sale price per unit.
   - **Minimum Stock Level**: Set threshold for low-stock warnings.
   - **Supplier Details** *(Optional)*: Tap to expand and enter vendor name/location.
4. Tap **Save Item**.

### Recording Stock Purchases
1. Open the Item Detail screen.
2. Tap **+ Purchase**.
3. Enter **Purchase Quantity** and **Unit Purchase Rate (₹)**.
4. Select **Date**, enter **Supplier Name** and **Notes**.
5. Check **Update item default purchase rate** if rate changed.
6. Tap **Save Purchase**. Stock quantity increases automatically.

### Adjusting Stock & Logging Wastage
1. Open the Item Detail screen (or tap **Adjust**).
2. Select Adjustment Type: **Increase (+)** or **Decrease (-)**.
3. Enter **Adjustment Quantity**.
4. Select **Reason**: *Recount / Correction*, *Damaged*, *Wastage*, *Lost*, or *Other*.
5. Select **Date** and enter **Notes** *(Required if reason is "Other")*.
6. Review the **Adjustment Preview** card.
7. Tap **Save Adjustment**.
   > [!NOTE]
   > Decreases cannot exceed available stock (stock cannot go below 0 via adjustment). Selecting **Wastage** logs the entry specifically for Wastage reporting.

---

## 5. Ready Stock Module (Colour Ledger)

The Ready Stock module is a dedicated colour-based ledger for finished stock transfers and dispatches. Ready stock items (`type == 'ready_stock'`) are separate from main raw materials and finished products so they don't clutter main inventory queries.

### Accessing Ready Stock
1. Open **Stock** screen and tap the **Ready Stock Module →** card at the top (or navigate to `/ready-stock`).
2. Displays all ready stock colours with current available stock in nag/units and status (**In Stock** or **Out of Stock**).

### Adding a Ready Stock Colour
1. Tap **+ Add Colour** on the Ready Stock screen.
2. Enter Colour Name (*e.g., Black, Navy Blue, Red*), Unit (*nag*), and Opening Quantity.
3. Tap **Save Item**.

### Recording Stock In (Incoming Stock Transfer)
1. Tap a colour card to open **Ready Stock Detail Screen**.
2. Tap **+ Stock In**.
3. Select **Movement Date**, enter **Quantity (nag)**, and enter an optional **Remark** (*e.g., Received from Cutting / Production*).
4. Tap **Record Stock In**. Stock quantity increases.

### Recording Stock Out (Outgoing Dispatch)
1. Tap **- Stock Out** on Ready Stock Detail Screen.
2. Select **Movement Date**, enter **Quantity (nag)**, and enter an optional **Remark** (*e.g., Dispatched to Party A*).
3. **Validation**: Quantity cannot exceed available stock. If quantity > available stock, the form shows a red error banner and disables the submit button (**Hard-Blocked**).
4. Tap **Record Stock Out**. Stock quantity decreases.

---

## 6. Worker Management, Material Issuance & Production

### Adding & Managing Workers
1. Tap **Workers** from the navigation bar.
2. Search by worker name, mobile, or skill.
3. Tap **+ Add Worker** (or **+** FAB).
4. Fill in details:
   - **Worker Name** *(Required)*.
   - **Mobile Number** (10 digits).
   - **Work Type / Skill**: Select from dropdown (*Tailor, Helper, Cutter, Master, Finishing, Pressing, Packing*) or type custom skill.
   - **Payment & Wages Setup**: Select Payment Type (**Hour**, **Piece**, or **Both**), Default Hourly Rate (₹/hr), and Default Piece Rate (₹/piece).
5. Tap **Save Worker**.

### Action Shortcuts on Worker Detail Screen
Every worker profile has 4 quick action buttons:
1. **+ Issue Material**: Issue raw materials to worker.
2. **+ Record Production**: Receive finished goods from worker and settle pending material.
3. **+ Add Work Entry**: Log daily work hours, pieces, and pay advance/wages.
4. **+ Cutting Entry**: Log daily colour cutting entries (nag).

### Workflow 1: Issuing Raw Material to Worker
1. Tap **+ Issue Material** on Worker Detail screen.
2. Select **Issuance Date**.
3. Select Raw Material item and enter **Quantity Issued**.
4. Tap **+ Add Another Item** to issue multiple materials in one voucher.
5. Tap **Save Issuance**. Raw material stock is deducted and added to worker's pending material balance.

### Workflow 2: Recording Finished Production Output
1. Tap **+ Record Production** on Worker Detail screen.
2. Select **Production Date**.
3. Select **Finished Product** and enter **Output Quantity**.
4. In the Material Consumption table, select raw materials used from worker's pending balance, enter **Consumed Qty**, and **Returned Qty** (if unused raw material was returned to shop stock).
5. Tap **Save Production**. Finished product stock increases, returned raw material stock increases, and worker's pending material balance is updated.

---

## 7. Worker Wages & Cutting System

### Log Daily Work & Wage Entry
1. Tap **+ Add Work Entry** on Worker Detail screen.
2. Select **Work Date**.
3. Enter **Hours Worked** and/or **Pieces Completed**.
   - Default rates fill automatically from worker profile. You can override the rate for today's entry without changing default rates.
   - App computes **Gross Wage Amount (₹)** live.
4. Enter **Advance / Payment Amount (₹)** paid today *(Optional)*.
   - Cannot exceed Gross Wage Amount.
   - App computes **Remaining Payable (₹)** and updates status:
     - **Paid**: Advance equals Gross Wage.
     - **Partial**: Partial advance paid.
     - **Unpaid**: Zero advance paid.
5. Tap **Save Entry** (or **Save & Add Another**).

### Log Worker Cutting Entry
1. Tap **+ Cutting Entry** on Worker Detail screen.
2. Select **Cutting Date**.
3. Select **Colour / Material** (shows available stock).
4. Enter **Cutting Qty (Nag)** and **Rate per Nag (₹)**.
   - App computes **Total Amount Earned (₹)** live.
   - If Cutting Qty > available stock, displays an amber warning card (*Warn-Only*, non-blocking).
5. Enter optional **Remark**.
6. Tap **Save Entry** (or **Save & Add Another**).
   - Raw material stock is deducted automatically with transaction type `'worker_cutting'`.
   - Earnings are tracked in worker's daily and monthly cutting summaries.

---

## 8. Billing, GST & PDF Invoices

### Creating a New Bill
1. Tap **Billing** from the navigation bar, then tap **+ Create Bill** (or **+** FAB).
2. **Select Customer**: Choose existing customer or tap **+ Add New Customer**. The app displays customer's current Outstanding Balance and Advance Held.
3. Select **Bill Date**.
4. **Add Items**:
   - Tap **+ Add Item Line** or select item from picker.
   - Enter **Quantity** and **Selling Rate (₹)**.
   - Line total computes automatically. Duplicate items are detected and focused.
   - Amber warning appears if quantity > current stock (non-blocking).
5. **Adjustments**:
   - Enter **Discount (₹)** *(Optional)*.
   - Enter **Other Charges (₹)** *(Optional, e.g., transport)*.
6. **Optional Per-Bill GST**:
   - Toggle **Enable GST** on/off.
   - When enabled, enter **GST %** *(default 18%)*.
   - App computes **Taxable Amount (₹)**, **GST Amount (₹)**, and **GST-Inclusive Grand Total (₹)** live.
7. **Apply Advance & Payment**:
   - **Apply Customer Advance**: If customer has advance credit, enter amount to apply against this bill.
   - App computes **Net Amount Payable**.
   - Enter **Amount Received Now (₹)**. Cannot exceed Net Amount Payable.
   - Select **Payment Method**: *Cash*, *UPI*, or *Other*.
   - Live status updates to **Paid**, **Partial**, or **Unpaid**.
8. Tap **Save Bill** (or **Save & Print Bill**).
   - Generates bill number (*e.g., INV-0001*).
   - Deducts item stock (*type: 'sold'*).
   - Updates customer ledger and account balance.

### Bill Detail & Actions
Open any bill from Billing screen to view:
- **Print / PDF**: Opens styled invoice PDF with boxed layout, header block, items table, GST details, **Amount in Words (Rupees & Paise)**, **Current Balance**, and VOIDED watermark (if voided).
- **Share via WhatsApp**: Sends bill summary message and PDF attachment on WhatsApp.
- **Record Payment**: Record partial or full balance payment for unpaid/partial bills. Amount entry is capped at remaining balance.
- **Void Bill**: Void bill with confirmation. Reverses stock deductions, reverses customer ledger entries, and watermarks PDF as VOIDED.

---

## 9. Payments, Printing & WhatsApp Sharing

### Standardized Bill Status Logic
All screens (Billing List, Bill Detail, Filter Chips, Customer Bills Tab, Reports) use **one single source of truth** for bill status:
- **Paid**: Remaining Balance = ₹0.
- **Unpaid**: Amount Paid = ₹0 (and Remaining Balance = Grand Total).
- **Partial**: Amount Paid > ₹0 AND Remaining Balance > ₹0.
- **Voided**: Bill marked as voided.

Filter chip counts (*All, Unpaid, Partial, Paid, Voided*) match table row status pills 100% consistently.

### WhatsApp Sharing Flow
1. Open Bill Detail screen.
2. Tap **Share via WhatsApp**.
3. App formats customer mobile number (*e.g., +91...*) and launches WhatsApp with pre-filled message:
   `"Hi [Name], here is your bill INV-xxxx dated [Date] for ₹[Total]. Remaining balance: ₹[Bal]. — [Shop Name]"`
4. App opens system share sheet to attach the generated Invoice PDF.

---

## 10. Reports & Business Analytics

Tap **Reports** from the navigation bar to access 8 real-time reports:

### Sales & Payments Reports
1. **Daily Sales Report**: Filter by date range. Shows daily gross sales, bill count, average bill value, and date-wise table with PDF/Excel export.
2. **Monthly Sales Report**: Select months back (3, 6, 12 months). Shows monthly gross sales, bill count, growth comparison, and monthly trends.
3. **Payment Report**: Filter by date range. Shows total collections with Cash, UPI, and Other breakdown.
4. **Customer Outstanding Report**: Ranks all customers by unpaid dues, total outstanding sum, and age.

### Stock Reports
5. **Stock Report**: Total inventory valuation (₹), total item count, category breakdown, raw materials vs finished goods vs ready stock.
6. **Stock Movement Report**: Date range filter & transaction type filter (*Purchase, Issuance, Adjustment, Sale, Cutting, Ready Stock*). Full audit log with PDF/Excel export.
7. **Low Stock Report**: Active items at or below minimum stock level with recommended reorder quantities.

### Worker Reports
8. **Worker Material Report**: Material issued, consumed in production, returned, and current pending stock held per worker.
9. **Worker Production Report**: Date range filter. Total finished product output by worker, batch count, and raw material consumption efficiency.

---

## 11. Data Safety: Backup, Restore & Excel Export

Tap **Settings** from the navigation bar to access data tools:

### Excel Data Export
- **Export All Data (.xlsx)**: One-click export that generates and shares all 10 Excel files:
  1. `Customers.xlsx`
  2. `Items.xlsx`
  3. `Stock_Transactions.xlsx`
  4. `Workers.xlsx`
  5. `Worker_Transactions.xlsx`
  6. `Production.xlsx`
  7. `Bills.xlsx`
  8. `Bill_Items.xlsx`
  9. `Payments.xlsx`
  10. `Customer_Ledger.xlsx`
- **Individual Exports**: Download individual Excel files for any single dataset.

### Backup & Restore
- **Create Backup**: Creates a timestamped `.json` / sqlite database backup file and opens share sheet.
- **Restore from Backup**: Select a backup file. The app validates file structure and timestamp, prompts for confirmation, replaces database, and safely closes the app to complete restoration.

### Danger Zone: Full Factory Reset
- **Full Factory Reset**: Wipes all application data (customers, items, workers, bills, payments, ledger) and resets bill counter to `INV-0001`.
- **Safety**: Requires typing **"RESET"** in capital letters in a confirmation dialog and offers a **Create Backup First** shortcut button.

---

## 12. Troubleshooting & Frequently Asked Questions

### Q1: Why can't I edit opening quantity for an existing item?
**Answer**: Opening quantity is fixed when an item is created to maintain historical integrity. To increase or decrease current stock, use **+ Purchase** or **Adjust Stock**.

### Q2: Why doesn't a Ready Stock colour show up on the main Stock screen?
**Answer**: Ready stock items (`type == 'ready_stock'`) are isolated in the **Ready Stock Module** (`/ready-stock`) to prevent mixing finished colour stock with raw materials. Tap the **Ready Stock Module →** banner on the main Stock screen to access them.

### Q3: Why is Stock Out blocked for a Ready Stock colour?
**Answer**: Ready Stock Out is hard-blocked if the requested quantity exceeds available stock. You must record a **+ Stock In** (transfer) or perform a stock adjustment before dispatching.

### Q4: Can I create a bill for a customer who owes money?
**Answer**: Yes. The app displays current outstanding dues and advance credit on the billing screen for your information, but does not block bill creation.

### Q5: What happens when I void a bill?
**Answer**: The bill status changes to **Voided**, stock sold in the bill is returned to inventory, customer ledger debit is reversed, and the PDF invoice is stamped with a **VOIDED** watermark.

---

## 13. Quick Workflow Cheat Sheet

| Task | Quick Navigation Path | Key Actions |
| :--- | :--- | :--- |
| **New Customer** | `Customers` → `+ Add Customer` | Use **Import from Contacts** for fast entry |
| **New Bill** | `Billing` → `+ Create Bill` | Select customer, add lines, toggle GST, apply advance, enter payment |
| **Record Payment** | `Billing` → Select Bill → `Record Payment` | Enter payment amount (capped at remaining balance), choose Cash/UPI |
| **Record Advance** | `Customers` → Select Customer → `Record Advance` | Enter deposit amount & method; saves to customer credit balance |
| **Add Stock Item** | `Stock` → `+ Add Item` | Set name, unit, opening qty, purchase & selling rates |
| **Stock Purchase** | `Stock` → Select Item → `+ Purchase` | Enter purchase qty and rate to update stock |
| **Ready Stock In/Out**| `Stock` → `Ready Stock Banner` → Select Colour | Tap **+ Stock In** or **- Stock Out** (hard-blocked on oversell) |
| **Issue Material** | `Workers` → Select Worker → `+ Issue Material` | Select raw material items & qty issued to worker |
| **Record Production**| `Workers` → Select Worker → `+ Record Production`| Select output item, qty, and log raw materials consumed |
| **Worker Wage Entry** | `Workers` → Select Worker → `+ Add Work Entry` | Enter hours/pieces, rate override, and advance paid today |
| **Worker Cutting** | `Workers` → Select Worker → `+ Cutting Entry` | Select colour & nag qty; deducts stock & tracks earnings |
| **Export Excel Data**| `Settings` → `Export All Data` | Generates 10 Excel sheets in one click |
| **Backup Database** | `Settings` → `Create Backup` | Creates timestamped backup file & opens share menu |

---

## 14. Summary of App Capabilities & Known Limitations

### Confirmed App Capabilities
- 100% offline local SQLite database with Riverpod state management.
- Real-time Dashboard with today's snapshot, stock overview, and recent bills.
- Complete Customer Directory with contact import, advance deposit ledger, and PDF statements.
- Dual-mode Inventory Management (Raw Materials vs Finished Products) with low-stock alerts and wastage tracking.
- Dedicated Ready Stock Module for colour-wise finished stock ledger with hard-blocked overselling on Stock Out.
- Complete Worker Module with material issuance, production logging, wage/piece tracking, and worker cutting entries.
- Flexible Billing with optional per-bill GST (configurable %), discount, freight charges, customer advance application, PDF generation (Amount in Words, Current Balance line), WhatsApp sharing, and bill voiding.
- 8 real-time business reports with PDF and Excel export options.
- Full backup, restore, single & multi-sheet Excel exports, and secure factory reset.

### Known Limitations
- **Device Printing**: PDF invoice printing requires a printer plugin/driver configured on Android/Windows.
- **WhatsApp Integration**: WhatsApp messaging relies on the device having WhatsApp or WhatsApp Business installed; otherwise, it falls back to the system share sheet.
