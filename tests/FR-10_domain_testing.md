# Domain Testing & Boundary Value Analysis: FR-10 Order Status (Order State Machine)

### STEP 1: Identify Input & Output Variables

**Input Variables:**
1. **Current State** (The current status of the order)
2. **Actor** (The user role attempting the action)
3. **Requested Action** (The transition event being triggered)

**Output Variables & Expected Outcomes:**
- **Success:** Order transitions successfully to the new state.
- **Error:** Appropriate error message (e.g., "Unauthorized", "Invalid transition", "Order is in a final state").

---

### STEP 2: Identify Equivalence Classes (Sub-domains)

Because a State Machine relies heavily on the combination of current state, actor, and action, we treat these combinations as a "Set of Values".

**1. Input: Current State (CS)**
* **CS_EC1 (Valid):** `pending`
* **CS_EC2 (Valid):** `confirmed`
* **CS_EC3 (Valid):** `shipping`
* **CS_EC4 (Invalid):** `delivered` (Final state — no outgoing transitions allowed)
* **CS_EC5 (Invalid):** `canceled` (Final state — no outgoing transitions allowed)

**2. Input: Actor (A)**
* **A_EC1 (Valid):** `Admin`
* **A_EC2 (Valid):** `User`

**3. Input: Requested Action (ACT)**
* **ACT_EC1 (Valid):** `Confirm`
* **ACT_EC2 (Valid):** `Ship`
* **ACT_EC3 (Valid):** `Complete`
* **ACT_EC4 (Valid):** `Cancel`
* **ACT_EC5 (Invalid):** Unrecognized action (e.g., `Refund`)

**4. Transition Sets (State + Actor + Action Combinations)**

*Valid Equivalence Classes (Allowed Transitions):*
* **VT_1:** `pending` + `Admin` + `Confirm` -> `confirmed`
* **VT_2:** `pending` + `Admin` + `Cancel` -> `canceled`
* **VT_3:** `pending` + `User` + `Cancel` -> `canceled`
* **VT_4:** `confirmed` + `Admin` + `Ship` -> `shipping`
* **VT_5:** `confirmed` + `Admin` + `Cancel` -> `canceled`
* **VT_6:** `confirmed` + `User` + `Cancel` -> `canceled`
* **VT_7:** `shipping` + `Admin` + `Complete` -> `delivered`
* **VT_8:** `shipping` + `Admin` + `Cancel` -> `canceled`

*Invalid Equivalence Classes (Disallowed Transitions):*
* **IT_1:** User attempts Admin-only action (e.g., `User` tries to `Confirm` a `pending` order).
* **IT_2:** User attempts a explicitly restricted Cancel (e.g., `User` tries to `Cancel` a `shipping` order).
* **IT_3:** Invalid state jump (e.g., `Admin` tries to `Ship` a `pending` order).
* **IT_4:** Invalid self-loop / reverse transition (e.g., `Admin` tries to `Confirm` an already `confirmed` order).
* **IT_5:** Any action attempted from the `delivered` final state.
* **IT_6:** Any action attempted from the `canceled` final state.

---

### STEP 3: Boundary Value Analysis

* **Applicability Check:** Boundary Value Analysis applies to continuous or ordered discrete numerical ranges (e.g., quantities, character limits, dates). 
* **Conclusion:** The Order State Machine inputs (States, Actors, Actions) are entirely **nominal/categorical**. There are no numerical boundaries defined in FR-10. Therefore, Boundary Value Analysis is **Not Applicable (N/A)** for this specific feature.

---

### STEP 4: Select Test Cases (Coverage Matrix)

*Note: In state machine testing, each valid transition must be tested individually. Invalid transitions are isolated to ensure error masking does not occur.*

| TC ID | Partitions Tested | Boundary Status | Current State | Actor | Requested Action | Expected Output | Actual | Status |
|---|---|---|---|---|---|---|---|---|
| **TC1** | CS_EC1, A_EC1, ACT_EC1 (VT_1) | N/A | `pending` | `Admin` | `Confirm` | Success: State changes to `confirmed` | | |
| **TC2** | CS_EC1, A_EC1, ACT_EC4 (VT_2) | N/A | `pending` | `Admin` | `Cancel` | Success: State changes to `canceled` | | |
| **TC3** | CS_EC1, A_EC2, ACT_EC4 (VT_3) | N/A | `pending` | `User` | `Cancel` | Success: State changes to `canceled` | | |
| **TC4** | CS_EC2, A_EC1, ACT_EC2 (VT_4) | N/A | `confirmed` | `Admin` | `Ship` | Success: State changes to `shipping` | | |
| **TC5** | CS_EC2, A_EC1, ACT_EC4 (VT_5) | N/A | `confirmed` | `Admin` | `Cancel` | Success: State changes to `canceled` | | |
| **TC6** | CS_EC2, A_EC2, ACT_EC4 (VT_6) | N/A | `confirmed` | `User` | `Cancel` | Success: State changes to `canceled` | | |
| **TC7** | CS_EC3, A_EC1, ACT_EC3 (VT_7) | N/A | `shipping` | `Admin` | `Complete` | Success: State changes to `delivered` | | |
| **TC8** | CS_EC3, A_EC1, ACT_EC4 (VT_8) | N/A | `shipping` | `Admin` | `Cancel` | Success: State changes to `canceled` | | |
| **TC9** | **IT_1** (User tries Admin action) | N/A | `pending` | `User` | `Confirm` | Error: Unauthorized action | | |
| **TC10** | **IT_2** (User tries restricted cancel)| N/A | `shipping` | `User` | `Cancel` | Error: Users cannot cancel shipped orders | | |
| **TC11** | **IT_3** (Invalid logical jump) | N/A | `pending` | `Admin` | `Ship` | Error: Invalid transition | | |
| **TC12** | **IT_4** (Invalid self-loop) | N/A | `confirmed` | `Admin` | `Confirm` | Error: Invalid transition | | |
| **TC13** | **CS_EC4**, **IT_5** (Final State) | N/A | `delivered` | `Admin` | `Cancel` | Error: Final state, no transitions allowed | | |
| **TC14** | **CS_EC5**, **IT_6** (Final State) | N/A | `canceled` | `Admin` | `Confirm` | Error: Final state, no transitions allowed | | |
| **TC15** | **ACT_EC5** (Invalid Action) | N/A | `pending` | `Admin` | `Refund` | Error: Unrecognized action | | |
