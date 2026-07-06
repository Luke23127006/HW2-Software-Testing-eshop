# Domain Testing & Boundary Value Analysis: FR-16 Import Products from CSV

### STEP 1: Identify Input & Output Variables

**Input Variables:**

1. **File Extension**: The format/extension of the uploaded file.
2. **File Header**: The first row of the uploaded CSV.
3. **Data Format**: Handling of commas inside values (RFC 4180).
4. **Row Data - Name**: The `name` field in a product row.
5. **Row Data - Price**: The `price` field in a product row.
6. **Transaction Context**: The combination of valid and invalid rows in a single file upload.

**Output Variables & Expected Outcomes:**

- **Success:** All rows are valid. The import succeeds, products are added, and a success report is displayed.
- **Error (File Level):** File is rejected due to invalid extension or invalid headers.
- **Error (Row Level & Rollback):** If _any_ row is invalid, the entire import is rolled back (no products added). A report is displayed showing successful vs. failed rows and reasons for failure.

---

### STEP 2: Identify Equivalence Classes (Sub-domains)

**1. Input: File Extension (EXT)**

- **EXT_EC1 (Valid):** `.csv`
- **EXT_EC2 (Invalid):** Non-csv extensions (e.g., `.txt`, `.xlsx`, `.pdf`)

**2. Input: File Header (HDR)**

- **HDR_EC1 (Valid):** Exactly `name,price,description,imageUrl,category_id`
- **HDR_EC2 (Invalid):** Missing headers, extra headers, or incorrect spelling/order.

**3. Input: Data Format (RFC 4180) (FMT)**

- **FMT_EC1 (Valid):** Standard comma-separated fields without internal commas.
- **FMT_EC2 (Valid):** Fields containing commas, correctly enclosed in double quotes (e.g., `"Product, Red"`).
- **FMT_EC3 (Invalid):** Fields containing commas NOT enclosed in double quotes (causes column mismatch).

**4. Input: Row Data - Name (NAME)**

- **NAME_EC1 (Valid):** Non-empty string.
- **NAME_EC2 (Invalid):** Empty string.

**5. Input: Row Data - Price (PRICE)**

- **PRICE_EC1 (Valid):** Positive number ($> 0$).
- **PRICE_EC2 (Invalid):** Zero or negative number ($\le 0$).
- **PRICE_EC3 (Invalid):** Non-numeric string (e.g., "abc").

**6. Input: Transaction & Rollback (TX)**

- **TX_EC1 (Valid):** File contains 100% valid rows.
- **TX_EC2 (Invalid):** File contains a mix of valid rows and at least one invalid row.

---

### STEP 3: Boundary Value Analysis

**1. Price Boundaries**

- The constraint is: "price must be a positive number" ($> 0$).
- **LB-1 (Invalid):** `0` (Maps to PRICE_EC2)
- **LB (Valid):** `1` (or `0.01` depending on smallest currency unit; using `1` as standard minimum for $\ge 1$). (Maps to PRICE_EC1)
- **Negative Value (Invalid):** `-1` (Maps to PRICE_EC2)

**2. Name Boundaries (Length)**

- The constraint is: "name cannot be empty".
- **LB (Invalid):** Empty string `""` (Length = 0).
- **LB+1 (Valid):** String with 1 character `"A"` (Length = 1).

---

### STEP 4: Select Test Cases (Coverage Matrix)

| TC ID   | Partitions Tested                                          | Boundary Status                 | File/Header                  | Row Data (Name, Price)                              | Transaction Context           | Expected Output                                                                                  | Actual                                                                                             | Status |
| ------- | ---------------------------------------------------------- | ------------------------------- | ---------------------------- | --------------------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| **TC1** | EXT_EC1, HDR_EC1, FMT_EC1, NAME_EC1, PRICE_EC1, TX_EC1     | **LB+1** (Name), **LB** (Price) | Valid `.csv`, Valid Header   | Name: `"A"`, Price: `1`                             | All rows valid                | Success: All rows imported. Report shows 100% success.                                           | Meet expectation                                                                                   | Pass   |
| **TC2** | EXT_EC1, HDR_EC1, **FMT_EC2**, NAME_EC1, PRICE_EC1, TX_EC1 | N/A                             | Valid `.csv`, Valid Header   | Name: `"Product, with comma"`, Price: `100`         | All rows valid                | Success: Product imported correctly without splitting the name field.                            | Meet expectation                                                                                   | Pass   |
| **TC3** | **EXT_EC2** (Invalid File Type)                            | N/A                             | Invalid `.txt` file          | N/A                                                 | N/A                           | Error: File format not supported / must be `.csv`.                                               | System fails to reject file, crashes / throws unhandled Server Error (500).                        | Fail   |
| **TC4** | **HDR_EC2** (Invalid Header)                               | N/A                             | Valid `.csv`, Invalid Header | N/A                                                 | N/A                           | Error: Invalid CSV header format.                                                                | Bypasses validation, reports success, and imports corrupted data (Name: -, Price: $NaN).           | Fail   |
| **TC5** | **NAME_EC2** (Invalid Name)                                | **LB** (Name Length = 0)        | Valid `.csv`, Valid Header   | Name: `""`, Price: `100`                            | 1 invalid row                 | Error: Name cannot be empty. Import rolled back.                                                 | Bypasses validation, reports success, and imports product with an empty name (-).                  | Fail   |
| **TC6** | **PRICE_EC2** (Invalid Price)                              | **LB-1** (Price = 0)            | Valid `.csv`, Valid Header   | Name: `"Test"`, Price: `0`                          | 1 invalid row                 | Error: Price must be positive. Import rolled back.                                               | Bypasses constraint, reports success, and imports product with price $0.00.                        | Fail   |
| **TC7** | **PRICE_EC2** (Invalid Price)                              | N/A                             | Valid `.csv`, Valid Header   | Name: `"Test"`, Price: `-50`                        | 1 invalid row                 | Error: Price must be positive. Import rolled back.                                               | Bypasses constraint, reports success, and imports product with negative price -$50.00.             | Fail   |
| **TC8** | **PRICE_EC3** (Non-numeric Price)                          | N/A                             | Valid `.csv`, Valid Header   | Name: `"Test"`, Price: `"abc"`                      | 1 invalid row                 | Error: Price must be a valid number. Import rolled back.                                         | Bypasses type validation, reports success, and imports product with corrupted price $NaN.          | Fail   |
| **TC9** | **TX_EC2** (Atomic Rollback Test)                          | N/A                             | Valid `.csv`, Valid Header   | Row 1: Valid Name/Price<br>Row 2: Invalid Price `0` | Mix of valid and invalid rows | Error: Entire import rolled back. Report: 1 success, 1 fail. 0 products actually imported to DB. | Transaction fails to rollback. Performs partial import (saves the valid row, ignores the invalid). | Fail   |
