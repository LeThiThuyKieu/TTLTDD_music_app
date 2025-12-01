# Music App Backend

Backend API cho ứng dụng nghe nhạc sử dụng Node.js, TypeScript, MySQL và Firebase.

## Công nghệ sử dụng

- **Node.js** với **TypeScript**
- **Express.js** - Web framework
- **MySQL** - Database
- **Firebase Admin SDK** - Authentication và Storage
- **express-validator** - Validation
- **Helmet** - Security
- **CORS** - Cross-Origin Resource Sharing
- **Morgan** - HTTP request logger

## Cấu trúc thư mục

````
backend/
├── src/                          # Source code chính
│   ├── config/                   # Cấu hình
│   │   ├── database.ts          # Kết nối MySQL
│   │   └── firebase.ts          # Kết nối Firebase Admin SDK
│   ├── controllers/              # Xử lý logic nghiệp vụ
│   │   ├── authController.ts
│   │   ├── userController.ts
│   │   ├── songController.ts
│   │   ├── playlistController.ts
│   │   ├── favoriteController.ts
│   │   └── historyController.ts
│   ├── middleware/               # Middleware (xử lý trung gian)
│   │   ├── auth.ts              # Xác thực Firebase token
│   │   └── errorHandler.ts      # Xử lý lỗi
│   ├── models/                   # Models tương tác với database
│   │   ├── User.ts
│   │   ├── Song.ts
│   │   ├── Playlist.ts
│   │   └── ...
│   ├── routes/                   # Định nghĩa API endpoints
│   │   ├── authRoutes.ts
│   │   ├── userRoutes.ts
│   │   ├── songRoutes.ts
│   │   └── ...
│   ├── types/                    # TypeScript type definitions
│   ├── utils/                    # Utilities (validation, helpers)
│   ├── app.ts                    # Setup Express app
│   └── server.ts                 # Entry point - khởi động server
├── database/
│   └── init.sql                  # Script tạo database và bảng
├── package.json                  # Dependencies và scripts
└── tsconfig.json                 # TypeScript config

## Cài đặt

### 1. Cài đặt dependencies

```bash
cd backend
npm install
````

### 2. Cấu hình môi trường

Tạo file `.env` từ `.env.example`:

```bash
cp .env.example .env
```

Cập nhật các giá trị trong file `.env`:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MySQL Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=music_app

# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-firebase-client-email
FIREBASE_STORAGE_BUCKET=your-firebase-storage-bucket.appspot.com
```

### 3. Tạo database

Chạy script SQL để tạo database và các bảng:

```bash
mysql -u root -p < database/init.sql
```

Hoặc mở MySQL và chạy file `database/init.sql`.

### 4. Cấu hình Firebase

1. Tạo project trên [Firebase Console](https://console.firebase.google.com/)
2. Tạo Service Account:
   - Vào Project Settings > Service Accounts
   - Click "Generate new private key"
   - Lấy các thông tin: `project_id`, `private_key`, `client_email`
3. Cập nhật vào file `.env`

### 5. Chạy server

**Development mode:**

```bash
npm run dev
```

**Production mode:**

```bash
npm run build
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

## API Endpoints

### Authentication

- `POST /api/auth/sync` - Đồng bộ user sau khi đăng nhập Firebase
- `GET /api/auth/me` - Lấy thông tin user hiện tại

### Users

- `PUT /api/users/profile` - Cập nhật profile
- `GET /api/users/:id` - Lấy thông tin user theo ID

### Songs

- `GET /api/songs` - Lấy danh sách bài hát
- `GET /api/songs/search?q=query` - Tìm kiếm bài hát
- `GET /api/songs/genre/:genreId` - Lấy bài hát theo genre
- `GET /api/songs/:id` - Lấy bài hát theo ID
- `POST /api/songs` - Tạo bài hát mới

### Playlists

- `POST /api/playlists` - Tạo playlist mới
- `GET /api/playlists/my` - Lấy playlists của user
- `GET /api/playlists/:id` - Lấy playlist theo ID
- `POST /api/playlists/:id/songs` - Thêm bài hát vào playlist
- `DELETE /api/playlists/:id/songs/:songId` - Xóa bài hát khỏi playlist
- `DELETE /api/playlists/:id` - Xóa playlist

### Favorites

- `GET /api/favorites` - Lấy danh sách favorites
- `GET /api/favorites/:songId/check` - Kiểm tra có trong favorites không
- `POST /api/favorites/:songId` - Thêm vào favorites
- `DELETE /api/favorites/:songId` - Xóa khỏi favorites

### History

- `GET /api/history` - Lấy lịch sử nghe
- `POST /api/history` - Thêm vào history
- `DELETE /api/history` - Xóa lịch sử

## Authentication

API sử dụng Firebase Authentication. Để gọi các API cần authentication:

1. Đăng nhập qua Firebase Auth trên client (Flutter)
2. Lấy Firebase ID Token
3. Gửi token trong header:

```
Authorization: Bearer <firebase-id-token>
```

## Database Schema

Xem file `database/init.sql` để biết chi tiết về cấu trúc database.

## Scripts

- `npm run dev` - Chạy server ở chế độ development với nodemon
- `npm run build` - Build TypeScript sang JavaScript
- `npm start` - Chạy server ở chế độ production
- `npm run lint` - Chạy ESLint

## Lưu ý

- Đảm bảo MySQL đang chạy trước khi start server
- Đảm bảo đã cấu hình Firebase đúng cách
- File `.env` không được commit lên git (đã có trong .gitignore)
