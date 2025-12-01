# Musea - Flutter Music App

Ứng dụng nghe nhạc được xây dựng bằng Flutter với backend Node.js/Express.

## Giới thiệu

Musea là ứng dụng nghe nhạc.

## Cấu trúc thư mục

````
mobile/
├── lib/                          # Source code chính (Dart)
│   ├── main.dart                # Entry point - Khởi tạo app
│   ├── config/                   # Cấu hình
│   │   ├── api_config.dart      # Base URL và API endpoints
│   │   └── app_config.dart      # App name, version, constants
│   ├── models/                   # Data models (tương ứng với database)
│   │   ├── user_model.dart      # Model cho User
│   │   ├── song_model.dart      # Model cho Song
│   │   ├── artist_model.dart     # Model cho Artist
│   │   └── playlist_model.dart   # Model cho Playlist
│   ├── screens/                  # UI Screens (màn hình)
│   │   └── splash_screen.dart   # Màn hình chào (Splash Screen)
│   ├── services/                 # Services - Xử lý logic nghiệp vụ
│   │   └── api_service.dart     # Service gọi API đến backend
│   └── utils/                    # Utilities
│       └── constants.dart       # Hằng số, error messages
├── android/                      # Android native code
│   └── app/src/main/
│       └── AndroidManifest.xml  # Android config
├── ios/                          # iOS native code (nếu có)
├── pubspec.yaml                  # Dependencies và config Flutter
└── README.md                     # Documentation

## Setup

### 1. Yêu cầu hệ thống

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code với Flutter extension
- Firebase project đã được tạo

### 2. Cài đặt dependencies

```bash
cd mobile
flutter pub get
````

### 3. Cấu hình Firebase

Firebase đã được tích hợp sẵn trong `main.dart`. Đảm bảo:

1. Đã tạo Firebase project trên [Firebase Console](https://console.firebase.google.com/)
2. Đã thêm file `google-services.json` vào `android/app/` (cho Android)
3. Đã thêm file `GoogleService-Info.plist` vào `ios/Runner/` (cho iOS)
4. Đã bật Firebase Authentication trong Firebase Console

### 4. Cấu hình API Base URL

Cập nhật file `lib/config/api_config.dart` với URL của backend server:

```dart
// Cho emulator Android:
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Cho thiết bị thật:
// static const String baseUrl = 'http://192.168.1.xxx:3000/api';
```

### 5. Cấu hình Android

File `android/app/src/main/AndroidManifest.xml` đã được cấu hình:

- Tên app: **Musea**
- Quyền Internet đã được thêm

## Chạy ứng dụng

### Chạy trên Android Emulator/Device

```bash
flutter run
```

### Chạy trên iOS (chỉ trên macOS)

```bash
flutter run -d ios
```

### Chạy trên Web

```bash
flutter run -d chrome
```

## Dependencies chính

- **firebase_core**: Firebase core
- **firebase_auth**: Firebase Authentication
- **firebase_storage**: Firebase Storage
- **http**: HTTP client cho API calls
- **go_router**: Routing và navigation
- **provider**: State management
- **audioplayers**: Phát nhạc
- **cached_network_image**: Load và cache images
- **shared_preferences**: Local storage

Xem chi tiết trong `pubspec.yaml`.

## Ghi chú

- App name: **Musea** (đã được cấu hình trong `app_config.dart` và `AndroidManifest.xml`)
- Backend API: Node.js/Express (xem thư mục `backend/`) + Typescript
- Firebase đã được khởi tạo tự động khi app chạy

## Troubleshooting

### Lỗi "AndroidManifest.xml could not be found"

Đã được fix bằng cách chạy `flutter create .` để tạo cấu trúc project đầy đủ.

### Lỗi Firebase initialization

Kiểm tra:

- File `google-services.json` đã được thêm vào `android/app/`
- Firebase project đã được tạo và cấu hình đúng

### Lỗi kết nối API

Kiểm tra:

- Backend server đã chạy
- Base URL trong `api_config.dart` đúng với môi trường (emulator/device)
