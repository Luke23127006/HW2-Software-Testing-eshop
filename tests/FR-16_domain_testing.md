# Domain Testing & Boundary Value Analysis: Cart Management (Quantity)
*(Note: The prompt requests testing for "FR-16: Cart Management". In the provided README, FR-16 is actually "Import Products from CSV," while Cart Management is covered under FR-06 and FR-07. The following analysis strictly applies Domain Testing to the Cart/Quantity features based on your specific directives).*

### STEP 1: Identify Input & Output Variables

**Input Variables:**
1. **Product Status (ID)**: The identifier/state of the product being added or updated in the cart.
2. **Quantity**: The requested number of items.

**Output Variables & Expected Outcomes:**
- **Success:** Product is added or cart quantity is updated; visual feedback (toast/badge) is displayed (per FR-06/FR-24).
- **Error:** System rejects the action with an appropriate message (e.g., "Invalid quantity", "Product not found").

---

### STEP 2: Identify Equivalence Classes (Sub-domains)

**1. Input: Product Status**
* *Rule applied: "Must Be" condition (Must be a valid existing product).* 
* *(CRITICAL COMPLIANCE NOTE: The README does not define inventory management, stock levels, or an "Out-of-Stock" state. Adhering strictly to the directive "Do not invent any constraints not explicitly written in the README", inventory/stock states are excluded from these equivalence classes).*
* **PS_EC1 (Valid):** Valid, existing Product ID.
* **PS_EC2 (Invalid):** Non-existent Product ID.

**2. Input: Quantity**
* *Rule applied: "Range" & "Must Be" (Must be a positive integer, minimum 1).*
* **QTY_EC1 (Valid):** Integer $\ge 1$.
* **QTY_EC2 (Invalid):** $0$.
* **QTY_EC3 (Invalid):** Negative integers ($< 0$).
* **QTY_EC4 (Invalid):** Non-integer numbers (decimals/floats).
* **QTY_EC5 (Invalid):** Non-numeric characters (e.g., letters, symbols).

---

### STEP 3: Boundary Value Analysis

**Quantity Boundaries**

* **Lower Boundary (LB = 1):** The README explicitly states "minimum is 1".
  * **LB-1 (Invalid):** `0` (Maps to QTY_EC2)
  * **LB (Valid):** `1` (Maps to QTY_EC1)
  * **LB+1 (Valid):** `2` (Maps to QTY_EC1)

* **Upper Boundary (UB = `MAX_INT`):** 
  * *(CRITICAL COMPLIANCE NOTE: The README explicitly lacks any "Maximum Stock limit". To strictly obey the rule not to invent business constraints, there is no business UB. However, to fulfill the BVA directive using basic mathematical/system logic, the UB is defined as the system's maximum allowable integer, denoted here as `MAX_INT`).*
  * **UB-1 (Valid):** `MAX_INT - 1`
  * **UB (Valid):** `MAX_INT`
  * **UB+1 (Invalid):** `MAX_INT + 1` (System integer overflow / technical rejection).

---

### STEP 4: Select Test Cases (Coverage Matrix)

*Note: Per strict isolation rules, invalid inputs are tested one at a time alongside a perfectly valid Product ID to prevent error masking.*

| TC ID | Partitions Tested | Boundary Status | Product Status | Quantity | Expected Output |
|---|---|---|---|---|---|
| **TC1** | PS_EC1, QTY_EC1 (Valid) | **LB** (Quantity) | Valid Product ID | `1` | Success: Added to cart, toast/badge updated |
| **TC2** | PS_EC1, QTY_EC1 (Valid) | **LB+1** (Quantity) | Valid Product ID | `2` | Success: Added to cart, toast/badge updated |
| **TC3** | PS_EC1, QTY_EC1 (Valid) | **UB-1** (Quantity) | Valid Product ID | `MAX_INT - 1` | Success: Added to cart, toast/badge updated |
| **TC4** | PS_EC1, QTY_EC1 (Valid) | **UB** (Quantity) | Valid Product ID | `MAX_INT` | Success: Added to cart, toast/badge updated |
| **TC5** | **PS_EC2** (Invalid) | LB (Quantity) | Non-existent Product ID | `1` | Error: Product not found |
| **TC6** | **QTY_EC2** (Invalid) | **LB-1** (Quantity) | Valid Product ID | `0` | Error: Quantity must be at least 1 |
| **TC7** | **QTY_EC3** (Invalid) | N/A | Valid Product ID | `-5` | Error: Quantity must be a positive integer |
| **TC8** | **QTY_EC4** (Invalid) | N/A | Valid Product ID | `1.5` | Error: Quantity must be an integer |
| **TC9** | **QTY_EC5** (Invalid) | N/A | Valid Product ID | `abc` | Error: Invalid quantity format |
| **TC10** | **System Limit** (Invalid)| **UB+1** (Quantity) | Valid Product ID | `MAX_INT + 1` | Error: Quantity exceeds system limits |
