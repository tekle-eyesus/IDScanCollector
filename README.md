# 🆔 IDScanCollector  

## 📌 Overview  
IDScanCollector is a Flutter-based application that enables data collectors to scan and extract user data from national IDs using Optical Character Recognition (OCR). The extracted data is stored in Firebase and synced with Google Sheets in real time for easy access and management.  

## 🚀 Features  
✅ **ID Scanning (OCR)** – Extracts text from IDs using Google ML Kit  
✅ **Real-Time Data Sync** – Stores scanned data in Firebase and Google Sheets  
✅ **Role-Based Authentication** – Secure login with Firebase Authentication  
✅ **Offline Mode** – Collect data even without an internet connection and sync later  
✅ **Data Validation & Security** – Prevents duplicates and ensures user privacy  

## 🏗 Tech Stack  
- **Frontend:** Flutter (Dart)  
- **OCR:** Google ML Kit / Tesseract OCR  
- **Backend:** Firebase (Firestore, Auth, Cloud Functions)  
- **Storage & Sync:** Google Sheets API  

## 🔧 Setup Instructions  
### 1️⃣ Prerequisites  
Ensure you have the following installed:  
- Flutter SDK (Latest version)  
- Dart  
- Firebase CLI  
- A Google Cloud Project (for Sheets API)  

### 2️⃣ Clone the Repository  
```sh
git clone https://github.com/YOUR_GITHUB_USERNAME/IDScanCollector.git
cd IDScanCollector
