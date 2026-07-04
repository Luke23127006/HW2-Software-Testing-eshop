# Main Report: Domain Testing & Boundary Value Analysis

## Feature: FR-03 Forgot Password & Reset Password
### 1. Domain Testing
* **Step 1: Input/Output Variables**
  * Inputs: Email Address, OTP, New Password, Confirm New Password
  * Outputs: Success (OTP sent, password reset), Error messages (Invalid format, unregistered email, invalid OTP, requirements not met, mismatch)
* **Step 2: Equivalence Classes**
  * Valid: Registered/valid email, Correct 6-digit OTP, Password >=8 chars with uppercase/lowercase/number/special char, Confirm password matches
  * Invalid: Unregistered/invalid email, Incorrect/different-email/expired/reused/wrong-format OTP, Password <8 chars or missing required char types, Confirm password mismatched
* **Step 3: Test Case Selection**
  * Valid classes were bundled together to minimize test cases and test happy paths, while invalid classes were tested independently with otherwise valid inputs to avoid error masking.

### 2. Boundary Value Analysis
* **Step 4: Boundary Identification**
  * OTP Length: LB-1 (5), LB (6), LB+1 (7)
  * New Password Length: LB-1 (7), LB (8), LB+1 (9)

### 3. AI Gap Analysis
* **Missed Test Cases/Bugs:** Missed global security constraint SEC-07 (OTP expiration/reused lifecycle), generated inconsistent test data for the "missing @" class (`test@eshop`), and missed the invisible trailing whitespace boundary for Confirm Password.
* **Reason:** Contextual tunnel vision. The AI focused solely on the specific feature block and failed to cross-reference the global security requirements table.

## Feature: FR-10 Order Status (Order State Machine)
### 1. Domain Testing
* **Step 1: Input/Output Variables**
  * Inputs: Current State, Actor (User/Admin), Requested Action (Confirm, Ship, Complete, Cancel)
  * Outputs: Success (State changed), Error (Unauthorized, invalid transition, final state)
* **Step 2: Equivalence Classes**
  * Valid: States (pending, confirmed, shipping), Actors (Admin, User), Actions (Confirm, Ship, Complete, Cancel), 8 valid transition sets (e.g. pending + Admin + Confirm)
  * Invalid: Final States (delivered, canceled), Unrecognized Actions, 6 invalid transition sets (e.g. User Admin-action, restricted cancel, logical jump, self-loop, action from final state)
* **Step 3: Test Case Selection**
  * Each valid transition was tested individually as state transitions are mutually exclusive. Invalid transitions were tested independently to ensure specific error states don't mask each other.

### 2. Boundary Value Analysis
* **Step 4: Boundary Identification**
  * Not Applicable. Inputs are nominal/categorical states, actors, and actions without numerical boundaries.

### 3. AI Gap Analysis
* **Missed Test Cases/Bugs:** None.
* **Reason:** The AI executed perfectly, successfully mapping the state machine transitions as a "Set of Values" and handling Actor constraints without hallucination.

## Feature: FR-19 User Management (Admin)
### 1. Domain Testing
* **Step 1: Input/Output Variables**
  * Inputs: Actor/Role (Token), Action (View, Delete), Target User ID (Other, Self)
  * Outputs: Success (Returns list, user deleted), Error (Unauthorized, Forbidden, Cannot delete self)
* **Step 2: Equivalence Classes**
  * Valid: Valid Admin JWT, View/Delete actions, Target ID = Other User
  * Invalid: User JWT, Unauthenticated, Target ID = Self (Logged-in admin)
* **Step 3: Test Case Selection**
  * Valid classes were bundled for happy paths. The invalid "Self-Deletion" constraint was explicitly tested using a valid Admin token to ensure authorization errors don't mask self-deletion logic failure.

### 2. Boundary Value Analysis
* **Step 4: Boundary Identification**
  * Not Applicable. Inputs consist of authorization states and logical entity comparisons (Self vs. Other), not numerical limits.

### 3. AI Gap Analysis
* **Missed Test Cases/Bugs:** None.
* **Reason:** The AI flawlessly cross-referenced global authorization rules (SEC-03) and correctly isolated the business logic for the Admin "Self-Deletion" constraint.

## Feature: FR-16 Cart Management (Quantity)
### 1. Domain Testing
* **Step 1: Input/Output Variables**
  * Inputs: Product Status (ID), Quantity
  * Outputs: Success (Added to cart/updated), Error (Invalid quantity, product not found)
* **Step 2: Equivalence Classes**
  * Valid: Existing Product ID, Quantity >= 1
  * Invalid: Non-existent Product ID, Quantity 0, negative, decimal, non-numeric
* **Step 3: Test Case Selection**
  * Invalid inputs (like quantity LB-1 or UB+1) were tested one at a time alongside a perfectly valid Product ID to strictly isolate errors and prevent error masking.

### 2. Boundary Value Analysis
* **Step 4: Boundary Identification**
  * Lower Boundary (LB=1): LB-1 (0), LB (1), LB+1 (2)
  * Upper Boundary (UB=MAX_INT): UB-1 (MAX_INT-1), UB (MAX_INT), UB+1 (MAX_INT+1)

### 3. AI Gap Analysis
* **Missed Test Cases/Bugs:** None.
* **Reason:** The AI correctly applied BVA math (LB, UB=MAX_INT) to the Cart Quantity and successfully avoided hallucinating unwritten inventory/stock constraints.