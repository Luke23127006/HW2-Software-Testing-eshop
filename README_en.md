# System Requirements Specification (SRS)

# EShop — Software Testing Edition

> **Document Scope**: Describes the **correct business requirements** of the EShop system.
> Students use this document as a basis for designing test cases, then test the actual system to find implementations that do not comply with the specification.

---

## 1. System Overview

The EShop system is an e-commerce platform consisting of 4 components:

| Component    | Technology                  | Default URL             |
| ------------ | --------------------------- | ----------------------- |
| Backend API  | Node.js + Express + SQLite  | `http://localhost:3000` |
| Frontend Web | React + Vite + Tailwind CSS | `http://localhost:5173` |
| Web Admin    | React + Vite + Tailwind CSS | `http://localhost:5174` |
| Mobile App   | React Native + Expo         | Server's LAN IP         |

**Default Accounts:**

- Admin: `admin@eshop.com` / `Admin123!`
- Test User: `test@eshop.com` / `Test1234!`

---

## 2. Account Management (Authentication & Authorization)

### FR-01: Account Registration

- Users must provide: **Full Name**, **Email**, **Password**.
- Email must have a valid format (`user@domain.com`) and be unique in the system.
- **Strong password requirement**: Minimum 8 characters, at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character (`@`, `$`, `!`, `%`, `*`, `?`, `&`).
- There must be a **Confirm Password** field — the system rejects if the two fields do not match.
- Upon successful registration, the user is redirected to the Login page.

### FR-02: Login & Account Lockout

- Users enter Email and Password.
- After each failed login attempt, the system increments the counter by **exactly 1**.
- If login fails **3 or more consecutive times**, the account is temporarily locked for **30 seconds** (demo environment). The system returns an appropriate error message; do not expose detailed cause.
- Successful login returns a JWT Token. The token is stored on the client side and sent with all authenticated requests via the `Authorization: Bearer <token>` header.
- The email field must use `type="email"` (with HTML5 format validation).

### FR-03: Forgot Password & Reset Password (2 steps)

**Step 1 — Get OTP:**

- User enters registered Email address.
- The system generates a **random 6-digit** OTP and sends it via Email (in demo environment: displayed directly on the screen).
- The interface must display a **Step Indicator** — e.g., "Step 1 / 2".
- There is a **Back to Login** button.

**Step 2 — Reset Password:**

- User enters OTP, New Password, and **Confirm New Password**.
- The new password must comply with conditions in FR-01.
- The two password fields must match.
- OTP is only valid for the requested email, cannot be used for another email.

### FR-04: Profile Management

- Logged-in users can update: **Full Name**, **Phone Number**, **Default Shipping Address**.
- **Valid phone number**: starts with `0`, 10–11 digits long.
- Email is not allowed to be changed via the interface.
- Users can only update their own profile; cannot self-modify the `role` attribute.

---

## 3. Categories & Products

### FR-05: View List & Search Products

- The homepage displays a list of all products in a grid.
- Each product displays: **Image** (standard ratio, with descriptive alt text), **Product Name**, **Price** (unit: ₫, thousands separator format).
- The search bar searches by product name. Search keywords must be **displayed safely** (no HTML rendering).
- While loading data, a **loading** state must be displayed.
- When there are no search results, an appropriate **empty state** message must be displayed.
- The homepage has **exactly one `<h1>` tag**.
- Each page has only 1 unique `<h1>`.

### FR-06: View Product Details

- Displays fully: Large Image, Name, Price, Description, Category.
- Has a **Quantity** input box (accepts only positive integers, minimum is 1).
- **Add to Cart** button — upon clicking, displays visual feedback (toast notification or badge update).

---

## 4. Shopping Cart & Checkout

### FR-07: Shopping Cart

- Displays a list of products with columns: **Product**, **Unit Price**, **Quantity** (with +/- buttons to adjust), **Total**, **Action**.
- Adding the same product to the cart will increase the quantity, not create a new row.
- **Delete product** button must have a confirmation dialog before executing.
- Has a **Continue Shopping** button to return to the homepage.
- The total amount displays the exact label: **"Total"** (not "Subtotal").
- An empty cart must have a clear illustration and message.

### FR-08: Checkout

- Only **logged-in** users can proceed to checkout.
- **Total checkout amount** is calculated automatically from the cart and does not allow users to modify it directly.
- The interface displays the full list of ordered products.
- The backend must recalculate the total amount itself; do not accept the `total_amount` value sent by the client.
- Upon successful checkout, the cart is cleared.

### FR-09: Discount Code (Coupon)

During Checkout, users can enter a discount code. The system applies the discount based on the following **5 conditions**, all must be satisfied:

| #   | Condition              | Description                                                       |
| --- | ---------------------- | ----------------------------------------------------------------- |
| C1  | **Code exists**        | The code must exist in the DB and be active (`is_active = 1`)     |
| C2  | **Not expired**        | The current date must be before `expired_at`                      |
| C3  | **Order threshold met**| Total order **>= (greater than or equal to)** `min_order_amount`  |
| C4  | **Logged in**          | The user must have a valid JWT Token                              |
| C5  | **Usage limit not met**| Number of times this user has used this code < `max_uses_per_user`|

**Discount Calculation Formula:**

- `percent` type: `discount_amount = total × discount_value / 100`
- `fixed` type: `discount_amount = discount_value`
- `final_amount = total - discount_amount`

**Sample Discount Codes in the system:**

| Code      | Type    | Value     | Min Threshold    | Expiry     | Uses/User    |
| --------- | ------- | --------- | ---------------- | ---------- | ------------ |
| `SAVE10`  | percent | 10%       | 300,000 ₫        | 2099-12-31 | 1            |
| `BIGBUY`  | fixed   | 50,000 ₫  | 500,000 ₫        | 2099-12-31 | 1            |
| `VIP100`  | fixed   | 100,000 ₫ | 300,000 ₫        | 2099-12-31 | 2            |
| `EXPIRED` | percent | 20%       | 100,000 ₫        | 2020-01-01 | 1            |

---

## 5. Order Management

### FR-10: Order Status (Order State Machine)

An order has **5 states** and must follow this transition diagram:

```
                 [Admin Confirms]          [Admin Ships]          [Admin Completes]
  ┌──────────┐ ─────────────────► ┌───────────┐ ──────────────► ┌──────────┐ ──────────► ┌───────────┐
  │ pending  │                    │ confirmed │                 │ shipping │             │ delivered │
  └──────────┘                    └───────────┘                 └──────────┘             └───────────┘
       │                               │
       │ [User/Admin Cancels]          │ [User/Admin Cancels]
       ▼                               ▼
  ┌──────────┐                    ┌──────────┐
  │ canceled │                    │ canceled │
  └──────────┘                    └──────────┘
```

**Final States Constraints:**

- `delivered` and `canceled` states are **final states** — no transitions to any other states are allowed.
- Once the order is in the `shipping` state, **Users are not allowed to self-cancel** — only Admins can perform this action.
- Any invalid transitions must return an error with an appropriate message.

### FR-11: View Order History (User)

- Users can only view their own orders.
- Display: Order ID, Order Date, Total Amount, Current Status.
- Statuses must be translated into clear English/Vietnamese and differentiated by color.

---

## 6. Web Admin Module

### FR-12: Access Control

- The Admin module is restricted to accounts with `role = 'admin'`.
- **All** Admin APIs (`/api/admin/*`) and data-modifying APIs (`POST/PUT/DELETE /api/products`, `/api/categories`, `/api/coupons`) must require:
  1. A valid JWT Token.
  2. `role = 'admin'` in the Token.

### FR-13: Dashboard

- Display total revenue: Only calculate the sum of `total_amount` for orders with `status = 'delivered'`.
- Display total number of orders.

### FR-14: Category Management (Category CRUD)

- Admins can Add / View / Delete categories.
- Category name is mandatory, cannot be empty.

### FR-15: Product Management (Product CRUD)

- Admins can Add / View / Edit / Delete products.
- **Input Validation:**
  - Product Name: mandatory, max 255 characters.
  - Price: mandatory, must be a **positive** number (> 0).
  - Category: mandatory, must be selected from an existing list.
- When Editing a product, only that product is modified — other products remain unchanged.

### FR-16: Import Products from CSV

- Admins can upload a CSV file to import multiple products at once.
- **CSV file requirements:**
  - File extension must be `.csv`.
  - The first row is the header: `name,price,description,imageUrl,category_id`.
  - Supports fields containing commas if enclosed in double quotes (RFC 4180).
- **Validation before import:**
  - `name` cannot be empty.
  - `price` must be a positive number.
- If there is an error in any row, the entire import must be **rolled back** (atomic transaction — all-or-nothing).
- The system displays a clear report: how many rows succeeded, how many rows failed, and the reasons.

### FR-17: Coupon Management (Coupon CRUD)

- Admins can Add / View / Delete discount codes.
- Mandatory fields: `code` (unique), `type` (percent/fixed), `discount_value` (positive), `expired_at`, `min_order_amount` (>= 0), `max_uses_per_user` (>= 1).

### FR-18: Order Management (Admin)

- Admins view all orders from all users.
- Admins can change order statuses according to the exact State Machine defined in FR-10.
- Shipping address must be displayed **safely** (no HTML rendering).

### FR-19: User Management (Admin)

- Admins view the list of all users (passwords are not exposed).
- Admins can delete users, **except they cannot delete the currently logged-in account**.

---

## 7. Mobile Module (React Native)

### FR-20: Mobile Features

- Full functionality: View Products, Login, Logout, Register, Cart, Checkout, Profile, Order History.
- The Order Cancellation feature follows the exact State Machine in FR-10 (can only be canceled when `pending` or `confirmed`).

---

## 8. GUI Requirements

### FR-21: General Interface Standards

- **Language consistency**: The entire interface uses Vietnamese (except for standard technical terms).
- **Color consistency**: Positive action buttons (Submit, Buy) use blue. Danger/cancel buttons use red.
- **Currency consistency**: Always use the `₫` symbol with thousands separator format.
- **Page titles**: Each page has exactly one `<h1>` tag describing the page content.
- **Tab Order**: Tab focus order must flow from top to bottom, left to right.

### FR-22: Form Requirements

- All mandatory fields must have an `*` symbol next to the label.
- Email fields must use `type="email"`.
- Password fields must use `type="password"` (masked).
- Error messages must appear **above** the submit button, not below.
- Forms with 2 or more steps must have a clear **Step Indicator**.

### FR-23: Navigation Requirements

- The Navigation bar (Navbar) must **highlight** the currently selected page.
- The "Cart" link must display a **quantity badge** for items in the cart.
- The Logout button must be labeled "Logout" (or equivalent clear term in Vietnamese).
- Breadcrumbs are mandatory on subpages (Cart, Checkout, Product Details).

### FR-24: Feedback & State Requirements

- After clicking "Add to Cart", there must be visual feedback (toast/badge).
- When removing an item from the cart, a confirmation dialog is required.
- Empty Pages (Empty State) must have an icon/illustration and a friendly message.
- All product images must have an `alt` attribute describing the image content (cannot be empty).

---

## 9. Security Requirements (Reference)

| ID     | Requirement                                                                                                     |
| ------ | --------------------------------------------------------------------------------------------------------------- |
| SEC-01 | Passwords must **not** be stored as plaintext.                                                                  |
| SEC-02 | Secure APIs must require a valid JWT Token.                                                                     |
| SEC-03 | Admin APIs must verify `role = 'admin'` in the Token, not just the existence of the Token.                      |
| SEC-04 | Any user input data displayed on the UI must be properly escaped; do not use `innerHTML` directly.              |
| SEC-05 | Database queries must use Parameterized Queries; no direct string concatenation.                                |
| SEC-06 | Profile update API must not allow changing the `role` field from the client.                                    |
| SEC-07 | Password reset OTP must have enough entropy (min 6 digits), have an expiration time, and be invalidated after use.|

---

_This document is for educational purposes and Software Testing practice. Version: 2.0 — Updated: 2026-05-14._
