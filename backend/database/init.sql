-- 1. Tạo database
CREATE DATABASE IF NOT EXISTS music_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Chọn database vừa tạo
USE music_app;

-- 3. Tạo bảng users
CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  email VARCHAR(200) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL, -- dùng bcrypt
  avatar_url VARCHAR(512),
  role ENUM('user', 'admin') DEFAULT 'user',
  is_active TINYINT DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 4. Tạo bảng artists
CREATE TABLE IF NOT EXISTS artists (
artist_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(200) NOT NULL,
avatar_url VARCHAR(512),
description TEXT,
is_active TINYINT DEFAULT 1
);

-- 5. Tạo bảng genres
CREATE TABLE IF NOT EXISTS genres (
genre_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(200) NOT NULL
);

-- 6. Tạo bảng albums
CREATE TABLE IF NOT EXISTS albums (
album_id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
artist_id INT,
cover_url VARCHAR(512),
release_date DATE,
is_active TINYINT DEFAULT 1,
FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- 7. Tạo bảng songs
CREATE TABLE IF NOT EXISTS songs (
song_id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
album_id INT,
genre_id INT,
duration INT,
lyrics LONGTEXT,
file_url VARCHAR(1024) NOT NULL,
cover_url VARCHAR(512),
release_date DATE,
is_active TINYINT DEFAULT 1,
FOREIGN KEY (album_id) REFERENCES albums(album_id),
FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- 8. Tạo bảng song_artists (N-N)
CREATE TABLE IF NOT EXISTS song_artists (
song_id INT NOT NULL,
artist_id INT NOT NULL,
PRIMARY KEY (song_id, artist_id),
FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE,
FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE
);

-- 9. Tạo bảng playlists
CREATE TABLE IF NOT EXISTS playlists (
playlist_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
name VARCHAR(255) NOT NULL,
cover_url VARCHAR(512),
is_public TINYINT DEFAULT 0,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 10. Tạo bảng playlist_songs
CREATE TABLE IF NOT EXISTS playlist_songs (
playlist_id INT NOT NULL,
song_id INT NOT NULL,
PRIMARY KEY (playlist_id, song_id),
FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
);

-- 11. Tạo bảng history
CREATE TABLE IF NOT EXISTS history (
history_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
song_id INT NOT NULL,
listened_at DATETIME DEFAULT CURRENT_TIMESTAMP,
listened_duration INT DEFAULT 0,
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
);

-- 12. Tạo bảng favorites
CREATE TABLE IF NOT EXISTS favorites (
user_id INT NOT NULL,
song_id INT NOT NULL,
PRIMARY KEY (user_id, song_id),
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
);




