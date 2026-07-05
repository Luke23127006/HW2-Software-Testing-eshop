# Domain Testing & Boundary Value Analysis: FR-03 Forgot Password & Reset Password

### STEP 1: Identify Input & Output Variables

**Input Variables:**

1. **Email Address** (Step 1)
2. **OTP** (Step 2)
3. **New Password** (Step 2)

**Output Variables & Expected Outcomes:**

- **Step 1 Success:** OTP sent successfully; UI displays step indicator "Step 1 / 2".
- **Step 1 Error:** Appropriate error message (e.g., "Invalid format" or "Unregistered email").
- **Step 2 Success:** Password reset successfully.
- **Step 2 Error:** Appropriate error message (e.g., "Invalid OTP", "Password requirements not met", "Passwords do not match").

---

### STEP 2: Identify Equivalence Classes (Sub-domains)

**1. Email Address (Input 1)**

- _Rule applied: "Must Be" condition (Must be registered & valid format)._
- **E_EC1 (Valid):** Registered email with a valid format (`user@domain.com`).
- **E_EC2 (Invalid):** Unregistered email address.
- **E_EC3 (Invalid):** Invalid email format (e.g., missing `@`).

**2. OTP (Input 2)**

- _Rule applied: "Must Be" condition (6 digits, valid for requested email)._
- **O_EC1 (Valid):** Correct 6-digit OTP requested for the target email.
- **O_EC2 (Invalid):** Valid 6-digit OTP, but requested for a _different_ email.
- **O_EC3 (Invalid):** Incorrect 6-digit OTP.
- **O_EC4 (Invalid):** Contains non-digit characters.
- **O_EC5 (Invalid):** Length < 6 characters.
- **O_EC6 (Invalid):** Length > 6 characters.
- **O_EC7 (Invalid):** Expired 6-digit OTP.
- **O_EC8 (Invalid):** Already used 6-digit OTP.

**3. New Password (Input 3)**

- _Rules applied: "Range" (>= 8 characters), "Must Be" (uppercase, lowercase, number), and "Set of Values" (special characters)._
- **NP_EC1 (Valid):** Length >= 8.
- **NP_EC2 (Valid):** Contains >= 1 uppercase letter.
- **NP_EC3 (Valid):** Contains >= 1 lowercase letter.
- **NP_EC4 (Valid):** Contains >= 1 number.
- **NP_EC5_1 to NP_EC5_7 (Valid Set):** Contains at least one of the specified special characters (`@`, `$`, `!`, `%`, `*`, `?`, `&` — 7 distinct valid classes).
- **NP_EC6 (Invalid):** Length < 8.
- **NP_EC7 (Invalid):** Missing uppercase letter.
- **NP_EC8 (Invalid):** Missing lowercase letter.
- **NP_EC9 (Invalid):** Missing number.
- **NP_EC10 (Invalid):** Missing any of the explicitly allowed special characters (e.g., contains `#` or no special characters at all).

---

### STEP 3: Boundary Value Analysis

**OTP Length (Constraint: Exact 6 digits)**

- **LB-1 (Invalid):** Length 5 (Maps to O_EC5)
- **LB (Valid):** Length 6 (Maps to O_EC1)
- **LB+1 (Invalid):** Length 7 (Maps to O*EC6)
  *(Since length is an exact value, Upper Bound and Lower Bound are the same).\_

**New Password Length (Constraint: Minimum 8 characters)**

- **LB-1 (Invalid):** Length 7 (Maps to NP_EC6)
- **LB (Valid):** Length 8 (Maps to NP_EC1)
- **LB+1 (Valid):** Length 9 (Maps to NP*EC1)
  *(No explicit upper limit is provided in the specification).\_

---

### STEP 4: Select Test Cases (Coverage Matrix)

_Note: Per the strict testing rules, Valid classes are bundled together where possible to minimize test cases, while Invalid classes are tested completely independently to avoid error masking._

| TC ID    | Partitions Tested                                    | Boundary Status                   | Email               | OTP               | New Password    | Expected Output                      | Actual                                                                     | Status  |
| -------- | ---------------------------------------------------- | --------------------------------- | ------------------- | ----------------- | --------------- | ------------------------------------ | -------------------------------------------------------------------------- | ------- |
| **TC1**  | E_EC1, O_EC1, NP_EC1,2,3,4, **NP_EC5_1** (All Valid) | LB (OTP Length)<br>LB (NP Length) | `test@eshop.com`    | `[Displayed OTP]` | `Aa1@bcde`      | Success, password reset              | System alerts: "Password too weak" even though the constraints are correct | Fail    |
| **TC2**  | **NP_EC5_2** (Valid)                                 | LB+1 (NP Length)                  | `test@eshop.com`    | `[Displayed OTP]` | `Aa1$bcdef`     | Success, password reset              | Blocked by the same validation error as TC1                                | Blocked |
| **TC3**  | **NP_EC5_3** (Valid)                                 | None                              | `test@eshop.com`    | `[Displayed OTP]` | `Aa1!bcde`      | Success, password reset              | Blocked by the same validation error as TC1                                | Blocked |
| **TC4**  | **NP_EC5_4** (Valid)                                 | None                              | `test@eshop.com`    | `[Displayed OTP]` | `Aa1%bcde`      | Success, password reset              | Blocked by the same validation error as TC1                                | Blocked |
| **TC5**  | **NP_EC5_5** (Valid)                                 | None                              | `test@eshop.com`    | `[Displayed OTP]` | `Aa1*bcde`      | Success, password reset              | Blocked by the same validation error as TC1                                | Blocked |
| **TC6**  | **NP_EC5_6** (Valid)                                 | None                              | `test@eshop.com`    | `[Displayed OTP]` | `Aa1?bcde`      | Success, password reset              | Blocked by the same validation error as TC1                                | Blocked |
| **TC7**  | **NP_EC5_7** (Valid)                                 | None                              | `test@eshop.com`    | `[Displayed OTP]` | `Aa1&bcde`      | Success, password reset              | Blocked by the same validation error as TC1                                | Blocked |
| **TC8**  | **E_EC2** (Invalid)                                  | None                              | `unknown@eshop.com` | _(Not Reached)_   | _(Not Reached)_ | Error: Email not registered          | Error: User not found                                                      |         |
| **TC9**  | **E_EC3** (Invalid)                                  | None                              | `testeshop.com`     | _(Not Reached)_   | _(Not Reached)_ | Error: Invalid email format          | Error: User not found                                                      |         |
| **TC10** | **O_EC2** (Invalid)                                  | LB (OTP Length)                   | `test@eshop.com`    | `[Other's OTP]`   | `Aa1@bcde`      | Error: OTP invalid for this email    | Unable to submit for testing due to password error in the form             | Blocked |
| **TC11** | **O_EC3** (Invalid)                                  | LB (OTP Length)                   | `test@eshop.com`    | `[Wrong OTP]`     | `Aa1@bcde`      | Error: Incorrect OTP                 | Unable to submit for testing due to password error in the form             | Blocked |
| **TC12** | **O_EC4** (Invalid)                                  | LB (OTP Length)                   | `test@eshop.com`    | `12345a`          | `Aa1@bcde`      | Error: Invalid OTP format            | Unable to submit for testing due to password error in the form             | Blocked |
| **TC13** | **O_EC5** (Invalid)                                  | **LB-1 (OTP Length)**             | `test@eshop.com`    | `12345`           | `Aa1@bcde`      | Error: OTP must be 6 digits          | Unable to submit for testing due to password error in the form             | Blocked |
| **TC14** | **O_EC6** (Invalid)                                  | **LB+1 (OTP Length)**             | `test@eshop.com`    | `1234567`         | `Aa1@bcde`      | Error: OTP must be 6 digits          | Unable to submit for testing due to password error in the form             | Blocked |
| **TC15** | **NP_EC6** (Invalid)                                 | **LB-1 (NP Length)**              | `test@eshop.com`    | `[Displayed OTP]` | `Aa1@bcd`       | Error: Minimum 8 characters          | Blocked by the same validation error as TC1                                | Blocked |
| **TC16** | **NP_EC7** (Invalid)                                 | LB (NP Length)                    | `test@eshop.com`    | `[Displayed OTP]` | `aa1@bcde`      | Error: Requires uppercase            | Blocked by the same validation error as TC1                                | Blocked |
| **TC17** | **NP_EC8** (Invalid)                                 | LB (NP Length)                    | `test@eshop.com`    | `[Displayed OTP]` | `AA1@BCDE`      | Error: Requires lowercase            | Blocked by the same validation error as TC1                                | Blocked |
| **TC18** | **NP_EC9** (Invalid)                                 | LB (NP Length)                    | `test@eshop.com`    | `[Displayed OTP]` | `Aa@bcdef`      | Error: Requires number               | Blocked by the same validation error as TC1                                | Blocked |
| **TC19** | **NP_EC10** (Invalid)                                | LB (NP Length)                    | `test@eshop.com`    | `[Displayed OTP]` | `Aa1#bcde`      | Error: Requires allowed special char | Blocked by the same validation error as TC1                                | Blocked |
| **TC21** | **O_EC7** (Invalid)                                  | None                              | `test@eshop.com`    | `[Expired OTP]`   | `Aa1@bcde`      | Error: OTP expired                   | Unable to submit for testing due to password error in the form             | Blocked |
| **TC22** | **O_EC8** (Invalid)                                  | None                              | `test@eshop.com`    | `[Used OTP]`      | `Aa1@bcde`      | Error: OTP already used              | Unable to submit for testing due to password error in the form             | Blocked |
