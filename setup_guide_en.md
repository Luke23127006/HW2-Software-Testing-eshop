# Setup & Launch Guide for EShop (System Under Test)

The EShop system consists of 3 main modules: Backend API, Frontend Web, and Frontend Mobile. To test the entire system, you need to run the Backend and at least one of the two Frontend platforms.

## Prerequisites
- **Node.js** installed (Version >= 18.x).
- `npm` package manager installed (usually comes with Node.js).
- (Optional) **Expo Go** application on your phone (iOS/Android) if you want to run the Frontend Mobile on a real device.

---

## 1. Launching Backend API

The Backend provides data and business logic for the entire system.

1. Open Terminal (Command Prompt / PowerShell / Terminal).
2. Navigate to the `backend` directory:
   ```bash
   cd EShop/backend
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Initialize the database and sample data (Seed Data). You only need to run this command once initially or when you want to reset the data:
   ```bash
   node database.js
   ```
5. Start the server:
   ```bash
   node server.js
   ```
   *The terminal will output: `Server is running on http://localhost:3000`.*
   *(Note: You must leave this Terminal running continuously during your testing).*

---

## 2. Launching Frontend Web

The Frontend Web is the main interface for users to shop via a browser.

1. Open a NEW Terminal window.
2. Navigate to the `frontend-web` directory:
   ```bash
   cd EShop/frontend-web
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the Web application:
   ```bash
   npm run dev
   ```
   *The terminal will provide a link (e.g., `http://localhost:5173/`). Click it or copy and paste it into your browser to use.*

---

## 3. Launching Frontend Mobile (Expo)

Frontend Mobile provides the App interface on mobile phones. (Note: The Backend must be running from step 1).

1. Open a NEW Terminal window.
2. Navigate to the `frontend-mobile` directory:
   ```bash
   cd EShop/frontend-mobile
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start Expo's Metro Bundler:
   ```bash
   npx expo start
   ```
5. **How to run the App:**
   - A QR Code will appear in the Terminal.
   - Use your phone to download the **Expo Go** app (from App Store or Google Play).
   - Open Expo Go and choose to Scan QR Code to open the app.
   - *Note: Your phone and computer must be on the same Wi-Fi network.*
   
   *(For Emulator/Simulator, you can press `a` to open on Android Emulator or `i` to open on iOS Simulator if installed).*

---

## 4. Launching Web Admin (For Administrators)

This is a new Web module added in Phase 2.

1. Open a NEW Terminal window.
2. Navigate to the `frontend-admin` directory:
   ```bash
   cd EShop/frontend-admin
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the Web Admin application:
   ```bash
   npm run dev
   ```
   *The terminal will provide the link `http://localhost:5174/`. To log in, use the default Admin account:*
   - **Email**: `admin@eshop.com`
   - **Password**: `admin123`

---

## Testing Guide

- Strictly adhere to the **System Requirements Specification (SRS)** document for reference.
- This system is **INTENTIONALLY** designed with many bugs related to:
  - User Interface (UI/UX)
  - Data Validation (Form Validation)
  - Security Vulnerabilities (SQL Injection, XSS, Authorization)
  - Business Logic Errors (Cart, Checkout).
- Try to find as many bugs as possible and fully document the Steps to Reproduce! Happy testing!
