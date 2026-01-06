-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for music_app
CREATE DATABASE IF NOT EXISTS `music_app` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE `music_app`;

-- Dumping structure for table music_app.albums
CREATE TABLE IF NOT EXISTS `albums` (
  `album_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `artist_id` int(11) DEFAULT NULL,
  `cover_url` varchar(512) DEFAULT NULL,
  `release_date` date DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT 1,
  PRIMARY KEY (`album_id`),
  UNIQUE KEY `title` (`title`),
  KEY `artist_id` (`artist_id`),
  CONSTRAINT `albums_ibfk_1` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.albums: ~5 rows (approximately)
DELETE FROM `albums`;
INSERT INTO `albums` (`album_id`, `title`, `artist_id`, `cover_url`, `release_date`, `is_active`) VALUES
	(1, 'Chúng Ta', 1, 'https://is1-ssl.mzstatic.com/image/thumb/Video211/v4/f0/66/61/f066611b-7c43-9828-389a-eb6eb5e12baa/Job84b233bc-78a8-4f70-b490-364be97d41ab-167536029-PreviewImage_Preview_Image_Intermediate_nonvideo_sdr_325854773_1760978097-Time1715042749638.png/316x316bb.webp', '2020-12-20', 1),
	(2, 'Tâm 9', 2, 'https://i.scdn.co/image/ab67616d0000b2734454611710af2f8df7f2fbfe', '2017-12-03', 1),
	(3, 'Show Của Đen', 3, 'https://i.scdn.co/image/ab67616d0000b2734888abe8ee4d110278a67538', '2022-05-27', 1),
	(4, 'Veston', 4, 'https://i1.sndcdn.com/artworks-000457791939-wrwc65-t500x500.jpg\r\n', '2019-12-10', 1),
	(5, 'Hoàng', 5, 'https://kenh14cdn.com/2019/10/21/800-500-1571634324911334973488.png', '2019-10-18', 1);

-- Dumping structure for table music_app.artists
CREATE TABLE IF NOT EXISTS `artists` (
  `artist_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT 1,
  PRIMARY KEY (`artist_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.artists: ~5 rows (approximately)
DELETE FROM `artists`;
INSERT INTO `artists` (`artist_id`, `name`, `avatar_url`, `description`, `is_active`) VALUES
	(1, 'Sơn Tùng M-TP', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcS0X52aE766v34_fcodYeawXEtTqtWDo8a_J89nPGplo9SoJj-c', 'Ca sĩ, nhạc sĩ nổi tiếng Việt Nam', 1),
	(2, 'Mỹ Tâm', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjWEdQsrGaw9U3pYzBiJ7FZaWzvqpJdGJeS54HZ5YxIjG3S9syTLxgln5hSBR8faHrl2ouBFr-7tSZoCuA9U67mxeH-_qREnc_0Wq7wItwBw&s=10', 'Nữ ca sĩ hàng đầu V-pop', 1),
	(3, 'Đen Vâu', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQR8oApeIfxXXrQYY-eg5uIxyYGsXcttYj4oGs3SNMiSPsHb-Ta6NJm5UIQkXYYSvC9_B3gggV93ehGth0vz53T_Ntw4COQjUKeROn9YZn2&s=10', 'Rapper nổi tiếng với phong cách đời', 1),
	(4, 'Hà Anh Tuấn', 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBwgHBgkIBwgKCgkLDRYPDQwMDRsUFRAWIB0iIiAdHx8kKDQsJCYxJx8fLT0tMTU3Ojo6Iys/RD84QzQ5OjcBCgoKDQwNGg8PGjclHyU3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3N//AABEIADgAOAMBEQACEQEDEQH/xAAbAAABBQEBAAAAAAAAAAAAAAAEAAECAwUHBv/EACkQAAIBAwMDAwQDAAAAAAAAAAECAwAEEQUhMQYSURRBQhMiYXEVMoH/xAAaAQACAwEBAAAAAAAAAAAAAAADBAECBQAG/8QAJREAAgMAAgIBBAMBAAAAAAAAAAECAxESIQQxQQUiUXGR0eET/9oADAMBAAIRAxEAPwDklLmtgq4niMWA5NSk2DlOEfbG7xU8WDd8NJeD5qMaLxlGXpiqCcFUn', 'Ca sĩ nhạc trữ tình, pop', 1),
	(5, 'Hoàng Thùy Linh', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf076tYM2G5m6kkNdE5KdANKTeILUzmNOif1VrWGUgnkmNz6nDpVFbjzMyOXgzZi8aOC9q9wafjDVgEx2y2NPGvZznZRdPo2ipIfcjn8wg-Q&s=10', 'Ca sĩ, nghệ sĩ giải trí Việt Nam', 1);

-- Dumping structure for table music_app.favorites
CREATE TABLE IF NOT EXISTS `favorites` (
  `user_id` int(11) NOT NULL,
  `song_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`song_id`),
  KEY `song_id` (`song_id`),
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`song_id`) REFERENCES `songs` (`song_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.favorites: ~0 rows (approximately)
DELETE FROM `favorites`;

-- Dumping structure for table music_app.genres
CREATE TABLE IF NOT EXISTS `genres` (
  `genre_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  PRIMARY KEY (`genre_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.genres: ~4 rows (approximately)
DELETE FROM `genres`;
INSERT INTO `genres` (`genre_id`, `name`) VALUES
	(4, 'Ballad'),
	(1, 'Pop'),
	(2, 'R&B'),
	(3, 'Rap');

-- Dumping structure for table music_app.history
CREATE TABLE IF NOT EXISTS `history` (
  `history_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `song_id` int(11) NOT NULL,
  `listened_at` datetime DEFAULT current_timestamp(),
  `listened_duration` int(11) DEFAULT 0,
  PRIMARY KEY (`history_id`),
  KEY `user_id` (`user_id`),
  KEY `song_id` (`song_id`),
  CONSTRAINT `history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `history_ibfk_2` FOREIGN KEY (`song_id`) REFERENCES `songs` (`song_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.history: ~0 rows (approximately)
DELETE FROM `history`;

-- Dumping structure for table music_app.playlists
CREATE TABLE IF NOT EXISTS `playlists` (
  `playlist_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `cover_url` varchar(512) DEFAULT NULL,
  `is_public` tinyint(4) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`playlist_id`),
  UNIQUE KEY `uq_user_playlist_name` (`user_id`,`name`),
  CONSTRAINT `playlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.playlists: ~1 rows (approximately)
DELETE FROM `playlists`;
INSERT INTO `playlists` (`playlist_id`, `user_id`, `name`, `cover_url`, `is_public`, `created_at`) VALUES
	(1, 1, 'My Playlists', NULL, 1, '2026-01-04 12:21:53');

-- Dumping structure for table music_app.playlist_songs
CREATE TABLE IF NOT EXISTS `playlist_songs` (
  `playlist_id` int(11) NOT NULL,
  `song_id` int(11) NOT NULL,
  PRIMARY KEY (`playlist_id`,`song_id`),
  KEY `song_id` (`song_id`),
  CONSTRAINT `playlist_songs_ibfk_1` FOREIGN KEY (`playlist_id`) REFERENCES `playlists` (`playlist_id`) ON DELETE CASCADE,
  CONSTRAINT `playlist_songs_ibfk_2` FOREIGN KEY (`song_id`) REFERENCES `songs` (`song_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.playlist_songs: ~5 rows (approximately)
DELETE FROM `playlist_songs`;
INSERT INTO `playlist_songs` (`playlist_id`, `song_id`) VALUES
	(1, 1),
	(1, 2),
	(1, 3),
	(1, 4),
	(1, 6);

-- Dumping structure for table music_app.songs
CREATE TABLE IF NOT EXISTS `songs` (
  `song_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `album_id` int(11) DEFAULT NULL,
  `genre_id` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `lyrics` longtext DEFAULT NULL,
  `file_url` varchar(1024) NOT NULL,
  `cover_url` varchar(512) DEFAULT NULL,
  `release_date` date DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT 1,
  PRIMARY KEY (`song_id`),
  UNIQUE KEY `uq_song_title_album` (`title`,`album_id`),
  UNIQUE KEY `uq_song_file` (`file_url`) USING HASH,
  KEY `album_id` (`album_id`),
  KEY `genre_id` (`genre_id`),
  CONSTRAINT `songs_ibfk_1` FOREIGN KEY (`album_id`) REFERENCES `albums` (`album_id`),
  CONSTRAINT `songs_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.songs: ~7 rows (approximately)
DELETE FROM `songs`;
INSERT INTO `songs` (`song_id`, `title`, `album_id`, `genre_id`, `duration`, `lyrics`, `file_url`, `cover_url`, `release_date`, `is_active`) VALUES
	(1, 'Chúng Ta Của Hiện Tại', 1, 1, 300, NULL, 'uploads/audio/chung_ta_cua_hien_tai.mp3', 'https://i.ytimg.com/vi/ryC6nsOk5l8/maxresdefault.jpg', '2020-12-20', 1),
	(2, 'Có Chắc Yêu Là Đây', 1, 1, 245, NULL, 'uploads/audio/co_chac_yeu_la_day.mp3', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6La6O9K4nknJTy8IrbsuOfIe5bRvB0z9p-w&s\r\n', '2020-07-05', 1),
	(3, 'Đừng Hỏi Em', 2, 2, 260, NULL, 'uploads/audio/dung_hoi_em.mp3', 'https://i.ytimg.com/vi/qBPFxyYli2E/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCT41Jch_BxB5GileAYbVOhptLPnQ', '2017-10-24', 1),
	(4, 'Mang Tiền Về Cho Mẹ', 3, 3, 230, NULL, 'uploads/audio/mang_tien_ve_cho_me.mp3', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJ9GNOed_WmCXa5xMIj6a73ksBY3RgKanoyQ&s', '2021-01-29', 1),
	(5, 'Đi Về Nhà', 3, 3, 240, NULL, 'uploads/audio/di_ve_nha.mp3', 'https://i.ytimg.com/vi/vTJdVE_gjI0/maxresdefault.jpg', '2020-12-16', 1),
	(6, 'Tháng Tư Là Lời Nói Dối Của Em', 4, 2, 290, NULL, 'uploads/audio/thang_4_la_loi_noi_doi_cua_em.mp3', 'https://i.ytimg.com/vi/UCXao7aTDQM/maxresdefault.jpg', '2018-01-14', 1),
	(7, 'Để Mị Nói Cho Mà Nghe', 5, 1, 240, NULL, 'uploads/audio/de_mi_noi_cho_ma_nghe.mp3', 'https://i.ytimg.com/vi/2Q0kIMGu91Y/sddefault.jpg', '2019-06-19', 1);

-- Dumping structure for table music_app.song_artists
CREATE TABLE IF NOT EXISTS `song_artists` (
  `song_id` int(11) NOT NULL,
  `artist_id` int(11) NOT NULL,
  PRIMARY KEY (`song_id`,`artist_id`),
  KEY `artist_id` (`artist_id`),
  CONSTRAINT `song_artists_ibfk_1` FOREIGN KEY (`song_id`) REFERENCES `songs` (`song_id`) ON DELETE CASCADE,
  CONSTRAINT `song_artists_ibfk_2` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.song_artists: ~7 rows (approximately)
DELETE FROM `song_artists`;
INSERT INTO `song_artists` (`song_id`, `artist_id`) VALUES
	(1, 1),
	(2, 1),
	(3, 2),
	(4, 3),
	(5, 3),
	(6, 4),
	(7, 5);

-- Dumping structure for table music_app.users
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `is_active` tinyint(4) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table music_app.users: ~1 rows (approximately)
DELETE FROM `users`;
INSERT INTO `users` (`user_id`, `name`, `email`, `password_hash`, `avatar_url`, `role`, `is_active`, `created_at`, `updated_at`) VALUES
	(1, 'Thuy Kieu', '22130137@st.hcmuaf.edu.vn', '$2a$10$zE4NGJ/laqMVkaRZVevsDe3tBFxDcsLbHZQdqG24KSkLvB7pYmY4S', '/uploads/avatar/avatar-1767368005686.png', 'user', 1, '2026-01-01 18:53:47', '2026-01-03 11:04:01'),
	(2, 'kieu1', 'thuykieu20040@gmail.com', '$2a$10$q4PE2s8S7gzVsvzXwrHCCOxHD/sYwMNRdEHQacSSkt4DBNFvS5Xc2', '/uploads/avatar/avatar-1767429492137.png', 'user', 1, '2026-01-03 15:37:01', '2026-01-03 22:56:36');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
