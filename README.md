# CDC - Comprehensive Dental Care

A modern Flutter-based dental practice management application designed to streamline patient management, treatment tracking, and clinical workflows for dental professionals.

## Table of Contents

- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [Screenshots](#screenshots)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Firebase Setup](#firebase-setup)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

CDC (Comprehensive Dental Care) is a comprehensive mobile application built specifically for dental professionals to manage their practice efficiently. The app provides an intuitive interface for patient management, treatment tracking, appointment scheduling, and secure data storage with cloud synchronization.

### Purpose
- Digitize dental practice management
- Improve patient data organization and accessibility
- Enhance treatment planning and tracking capabilities
- Provide secure, cloud-based data storage
- Streamline clinical workflows

### Target Audience
- Dental practitioners
- Dental clinics and hospitals
- Dental assistants and hygienists
- Practice administrators

## Key Features

### 🔐 **Authentication & Security**
- Secure user registration and login
- Firebase Authentication integration
- Password reset functionality
- Multi-factor authentication support

### 👨‍⚕️ **Doctor Profile Management**
- Comprehensive professional profile setup
- Profile image upload via Pinata IPFS
- Specialization and clinic information
- Secure password management
- Real-time profile updates

### 👥 **Patient Management**
- Complete patient information system
- Add, edit, and delete patient records
- Advanced search and filtering capabilities
- Patient status tracking (Active, Follow-up, Completed)
- Comprehensive patient history

### 📋 **Treatment Tracking**
- Detailed treatment history recording
- Session tracking with remaining sessions
- Cost management and billing integration
- Treatment progress monitoring
- Multiple treatment plans per patient

### 📁 **File Management**
- X-ray and medical report uploads
- Image storage via Pinata IPFS
- Multiple file format support (PDF, JPG, PNG)
- Secure cloud storage
- Easy file viewing and management

### 🔍 **Advanced Search & Filtering**
- Real-time patient search
- Filter by patient status
- Search by name, phone, or address
- Results counter and pagination
- Intuitive user interface

### 📊 **Dashboard & Analytics**
- Professional dashboard interface
- Patient statistics overview
- Treatment progress tracking
- Quick access to key features
- Customizable widgets

### 🎨 **User Experience**
- Modern, intuitive interface design
- Smooth animations and transitions
- Responsive design for various screen sizes
- Dark/light theme support
- Accessibility features

## Screenshots

### Authentication Screens

<img src="https://github.com/user-attachments/assets/72b31ac0-7217-49f1-a333-137aabbd58ec" alt="Login Screen" width="300" height="600">
<img src="https://github.com/user-attachments/assets/4ece5e67-c654-4811-9f55-51fb4127cde9" alt="Registration Screen" width="300" height="600">
<img src="https://github.com/user-attachments/assets/e6741be1-bc00-4e00-b663-e0c7b6e51001" alt="Password Reset Screen" width="300" height="600">

### Dashboard & Profile

<img src="https://github.com/user-attachments/assets/700def97-4284-4899-bb5f-6e09cee29f30" alt="Dashboard Screen" width="300" height="600">
<img src="https://github.com/user-attachments/assets/5fad0b32-35d5-4758-b88e-2dd40da87b27" alt="Profile Screen" width="300" height="600">

### Patient Management

<img src="https://github.com/user-attachments/assets/17ed94e1-ce23-4a7e-b9ed-bf157943540d" alt="Patient List" width="300" height="600">
<img src="https://github.com/user-attachments/assets/01f00384-d522-44f2-a562-fe0796e3c9dd" alt="Add Patient" width="300" height="600">
<img src="https://github.com/user-attachments/assets/350dba92-98e8-4526-ba44-855f303ed0ab" alt="Patient Details" width="300" height="600">

### Treatment & Files

<img src="https://github.com/user-attachments/assets/9e0c43a1-926c-4752-8e03-2b3ef10b9ce6" alt="Treatment Tracking" width="300" height="600">

## Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Material Design** - UI/UX framework

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Pinata IPFS** - Decentralized file storage

### Development Tools
- **Android Studio / VS Code** - IDE
- **Firebase Console** - Backend management
- **Git** - Version control

## Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code
- Firebase project setup
- Pinata account for IPFS storage

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com//cdc-dental-care.git
   cd cdc-dental-care
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project
   - Add Android/iOS app to your Firebase project
   - Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
   - Place the configuration files in the appropriate directories

4. **Configure Pinata**
   - Create a Pinata account at [pinata.cloud](https://pinata.cloud)
   - Generate API keys
   - Update `PinataService` with your API credentials

5. **Run the application**
   ```bash
   flutter run
   ```

## Usage

### Getting Started

1. **Register/Login**
   - Create a new account or login with existing credentials
   - Complete your professional profile setup

2. **Patient Management**
   - Add new patients with comprehensive information
   - Use search and filter features to find patients quickly
   - Update patient records as needed

3. **Treatment Tracking**
   - Record treatment sessions and progress
   - Upload X-rays and medical reports
   - Track treatment costs and remaining sessions

4. **Profile Management**
   - Update professional information
   - Change profile picture
   - Modify security settings

### Best Practices

- Regularly backup important data
- Keep patient information updated
- Use secure passwords
- Review and update treatment plans regularly

## Firebase Setup

### Database Structure
```
users/
  ├── {userId}/
      ├── name: string
      ├── email: string
      ├── phone: string
      ├── specialization: string
      ├── clinicName: string
      ├── address: string
      ├── profileImageUrl: string
      └── patients/
          ├── {patientId}/
              ├── name: string
              ├── age: number
              ├── phone: string
              ├── address: string
              ├── status: string
              ├── treatments: array
              ├── reportFiles: array
              └── notes: string
```

**CDC - Comprehensive Dental Care** | Making dental practice management simple and efficient.
