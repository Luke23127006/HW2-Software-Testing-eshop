# Domain Testing & Boundary Value Analysis: FR-19 User Management (Admin)

### STEP 1: Identify Input & Output Variables

**Input Variables:**

1. **Actor/Role** (Authorization context based on JWT Token presence and role, per FR-12 and SEC-03)
2. **Action** (The specific operation being requested)
3. **Target User ID** (The account identifier to be deleted, only applicable for Delete action)

**Output Variables & Expected Outcomes:**

- **Success (View):** Returns a list of all users without exposing passwords.
- **Success (Delete):** Target user is successfully deleted from the system.
- **Error:** Appropriate error message (e.g., "Unauthorized - Missing Token", "Forbidden - Admin role required", "Cannot delete currently logged-in account").

---

### STEP 2: Identify Equivalence Classes (Sub-domains)

**1. Input: Actor/Role**

- _Rule applied: "Must Be" condition (Valid JWT AND role='admin')._
- **A_EC1 (Valid):** Valid JWT Token with `role = 'admin'`
- **A_EC2 (Invalid):** Valid JWT Token with `role = 'user'` (or any non-admin role)
- **A_EC3 (Invalid):** Unauthenticated (Missing, expired, or invalid JWT Token)

**2. Input: Action**

- _Rule applied: "Set of Values" (View List, Delete)._
- **ACT_EC1 (Valid):** View User List
- **ACT_EC2 (Valid):** Delete User

**3. Input: Target User ID**

- _Rule applied: "Must Be" condition (Must NOT be the currently logged-in account)._
- **TID_EC1 (Valid):** Other User (An existing user ID different from the logged-in admin).
- **TID_EC2 (Invalid):** Self (The user ID of the currently logged-in admin making the request).
- **TID_EC3 (N/A):** Not Applicable (For the "View User List" action, no target ID is provided).

---

### STEP 3: Boundary Value Analysis

- **Applicability Check:** The inputs for this feature consist of authorization states (Token/Role), categorical actions (View/Delete), and logical entity comparisons (Self vs. Other). There are no numerical ranges, sequence limits, or ordered continuous variables defined in the SRS for User Management.
- **Conclusion:** Boundary Value Analysis (BVA) is **Not Applicable (N/A)** for this feature. The constraint of "Self vs. Other" is a categorical logical condition, not a numerical boundary limit.

---

### STEP 4: Select Test Cases (Coverage Matrix)

_Note: Valid classes are combined to test happy paths. Invalid classes (Actor/Role constraints and the Self-Deletion constraint) are isolated. For example, when testing the invalid "Self-Deletion" constraint, the request uses a perfectly valid Admin token to ensure an authorization failure does not mask the self-deletion logic failure._

| TC ID   | Partitions Tested               | Boundary Status | Actor/Role      | Action         | Target User ID | Expected Output                                  | Actual | Status |
| ------- | ------------------------------- | --------------- | --------------- | -------------- | -------------- | ------------------------------------------------ | ------ | ------ |
| **TC1** | A_EC1, ACT_EC1, TID_EC3 (Valid) | N/A             | Valid Admin     | View User List | N/A            | Success: Returns user list (passwords hidden)    |        |        |
| **TC2** | A_EC1, ACT_EC2, TID_EC1 (Valid) | N/A             | Valid Admin     | Delete User    | Other User     | Success: User is deleted                         |        |        |
| **TC3** | **A_EC2** (Invalid)             | N/A             | Valid User      | View User List | N/A            | Error: Forbidden (Requires Admin)                |        |        |
| **TC4** | **A_EC2** (Invalid)             | N/A             | Valid User      | Delete User    | Other User     | Error: Forbidden (Requires Admin)                |        |        |
| **TC5** | **A_EC3** (Invalid)             | N/A             | Unauthenticated | View User List | N/A            | Error: Unauthorized (Token required)             |        |        |
| **TC6** | **A_EC3** (Invalid)             | N/A             | Unauthenticated | Delete User    | Other User     | Error: Unauthorized (Token required)             |        |        |
| **TC7** | **TID_EC2** (Invalid)           | N/A             | Valid Admin     | Delete User    | **Self**       | Error: Cannot delete currently logged-in account |        |        |
