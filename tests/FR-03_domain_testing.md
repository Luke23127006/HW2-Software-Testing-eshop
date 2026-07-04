# Domain Testing & Boundary Value Analysis: FR-03 Forgot Password & Reset Password

### STEP 1: Identify Input & Output Variables

**Input Variables:**
1. **Email Address** (Step 1)
2. **OTP** (Step 2)
3. **New Password** (Step 2)
4. **Confirm New Password** (Step 2)

**Output Variables & Expected Outcomes:**
- **Step 1 Success:** OTP sent successfully; UI displays step indicator "Step 1 / 2".
- **Step 1 Error:** Appropriate error message (e.g., "Invalid format" or "Unregistered email").
- **Step 2 Success:** Password reset successfully.
- **Step 2 Error:** Appropriate error message (e.g., "Invalid OTP", "Password requirements not met", "Passwords do not match").

---

### STEP 2: Identify Equivalence Classes (Sub-domains)

**1. Email Address (Input 1)**
* *Rule applied: "Must Be" condition (Must be registered & valid format).*
* **E_EC1 (Valid):** Registered email with a valid format (`user@domain.com`).
* **E_EC2 (Invalid):** Unregistered email address.
* **E_EC3 (Invalid):** Invalid email format (e.g., missing `@`).

**2. OTP (Input 2)**
* *Rule applied: "Must Be" condition (6 digits, valid for requested email).*
* **O_EC1 (Valid):** Correct 6-digit OTP requested for the target email.
* **O_EC2 (Invalid):** Valid 6-digit OTP, but requested for a *different* email.
* **O_EC3 (Invalid):** Incorrect 6-digit OTP.
* **O_EC4 (Invalid):** Contains non-digit characters.
* **O_EC5 (Invalid):** Length < 6 characters.
* **O_EC6 (Invalid):** Length > 6 characters.

**3. New Password (Input 3)**
* *Rules applied: "Range" (>= 8 characters), "Must Be" (uppercase, lowercase, number), and "Set of Values" (special characters).*
* **NP_EC1 (Valid):** Length >= 8.
* **NP_EC2 (Valid):** Contains >= 1 uppercase letter.
* **NP_EC3 (Valid):** Contains >= 1 lowercase letter.
* **NP_EC4 (Valid):** Contains >= 1 number.
* **NP_EC5_1 to NP_EC5_7 (Valid Set):** Contains at least one of the specified special characters (`@`, `$`, `!`, `%`, `*`, `?`, `&` — 7 distinct valid classes).
* **NP_EC6 (Invalid):** Length < 8.
* **NP_EC7 (Invalid):** Missing uppercase letter.
* **NP_EC8 (Invalid):** Missing lowercase letter.
* **NP_EC9 (Invalid):** Missing number.
* **NP_EC10 (Invalid):** Missing any of the explicitly allowed special characters (e.g., contains `#` or no special characters at all).

**4. Confirm New Password (Input 4)**
* *Rule applied: "Must Be" condition (Must match New Password).*
* **CP_EC1 (Valid):** Matches New Password exactly.
* **CP_EC2 (Invalid):** Does not match New Password.

---

### STEP 3: Boundary Value Analysis

**OTP Length (Constraint: Exact 6 digits)**
* **LB-1 (Invalid):** Length 5 (Maps to O_EC5)
* **LB (Valid):** Length 6 (Maps to O_EC1)
* **LB+1 (Invalid):** Length 7 (Maps to O_EC6)
*(Since length is an exact value, Upper Bound and Lower Bound are the same).*

**New Password Length (Constraint: Minimum 8 characters)**
* **LB-1 (Invalid):** Length 7 (Maps to NP_EC6)
* **LB (Valid):** Length 8 (Maps to NP_EC1)
* **LB+1 (Valid):** Length 9 (Maps to NP_EC1)
*(No explicit upper limit is provided in the specification).*

---

### STEP 4: Select Test Cases (Coverage Matrix)

*Note: Per the strict testing rules, Valid classes are bundled together where possible to minimize test cases, while Invalid classes are tested completely independently to avoid error masking.*

| TC ID | Partitions Tested | Boundary Status | Email | OTP | New Password | Confirm Password | Expected Output |
|---|---|---|---|---|---|---|---|
| **TC1** | E_EC1, O_EC1, CP_EC1, NP_EC1,2,3,4, **NP_EC5_1** (All Valid) | LB (OTP Length)<br>LB (NP Length) | `user@test.com` | `123456` | `Aa1@bcde` | `Aa1@bcde` | Success, password reset |
| **TC2** | **NP_EC5_2** (Valid) | LB+1 (NP Length) | `user@test.com` | `123456` | `Aa1$bcdef` | `Aa1$bcdef` | Success, password reset |
| **TC3** | **NP_EC5_3** (Valid) | None | `user@test.com` | `123456` | `Aa1!bcde` | `Aa1!bcde` | Success, password reset |
| **TC4** | **NP_EC5_4** (Valid) | None | `user@test.com` | `123456` | `Aa1%bcde` | `Aa1%bcde` | Success, password reset |
| **TC5** | **NP_EC5_5** (Valid) | None | `user@test.com` | `123456` | `Aa1*bcde` | `Aa1*bcde` | Success, password reset |
| **TC6** | **NP_EC5_6** (Valid) | None | `user@test.com` | `123456` | `Aa1?bcde` | `Aa1?bcde` | Success, password reset |
| **TC7** | **NP_EC5_7** (Valid) | None | `user@test.com` | `123456` | `Aa1&bcde` | `Aa1&bcde` | Success, password reset |
| **TC8** | **E_EC2** (Invalid) | None | `unknown@test.com`| *(Not Reached)* | *(Not Reached)* | *(Not Reached)* | Error: Email not registered |
| **TC9** | **E_EC3** (Invalid) | None | `user@domain` | *(Not Reached)* | *(Not Reached)* | *(Not Reached)* | Error: Invalid email format |
| **TC10** | **O_EC2** (Invalid) | LB (OTP Length) | `user@test.com` | `654321` (Other's OTP) | `Aa1@bcde` | `Aa1@bcde` | Error: OTP invalid for this email |
| **TC11** | **O_EC3** (Invalid) | LB (OTP Length) | `user@test.com` | `000000` (Wrong OTP) | `Aa1@bcde` | `Aa1@bcde` | Error: Incorrect OTP |
| **TC12** | **O_EC4** (Invalid) | LB (OTP Length) | `user@test.com` | `12345a` | `Aa1@bcde` | `Aa1@bcde` | Error: Invalid OTP format |
| **TC13** | **O_EC5** (Invalid) | **LB-1 (OTP Length)** | `user@test.com` | `12345` | `Aa1@bcde` | `Aa1@bcde` | Error: OTP must be 6 digits |
| **TC14** | **O_EC6** (Invalid) | **LB+1 (OTP Length)** | `user@test.com` | `1234567` | `Aa1@bcde` | `Aa1@bcde` | Error: OTP must be 6 digits |
| **TC15** | **NP_EC6** (Invalid) | **LB-1 (NP Length)** | `user@test.com` | `123456` | `Aa1@bcd` | `Aa1@bcd` | Error: Minimum 8 characters |
| **TC16** | **NP_EC7** (Invalid) | LB (NP Length) | `user@test.com` | `123456` | `aa1@bcde` | `aa1@bcde` | Error: Requires uppercase |
| **TC17** | **NP_EC8** (Invalid) | LB (NP Length) | `user@test.com` | `123456` | `AA1@BCDE` | `AA1@BCDE` | Error: Requires lowercase |
| **TC18** | **NP_EC9** (Invalid) | LB (NP Length) | `user@test.com` | `123456` | `Aa@bcdef` | `Aa@bcdef` | Error: Requires number |
| **TC19** | **NP_EC10** (Invalid) | LB (NP Length) | `user@test.com` | `123456` | `Aa1#bcde` | `Aa1#bcde` | Error: Requires allowed special char |
| **TC20** | **CP_EC2** (Invalid) | LB (NP Length) | `user@test.com` | `123456` | `Aa1@bcde` | `Aa1@bcdd` | Error: Passwords do not match |
