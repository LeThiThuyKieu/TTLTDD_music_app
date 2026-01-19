import pool from "../../config/database";
// import { AdminSong } from "../../models/admin/adminSong.model";
import { SongWithArtists } from "../../models/Song";
import { Artist } from "../../models/Artist";
import { deleteFromCloudinary } from "../../config/cloudinary";

export class AdminSongRepository {
  // LẤY DANH SÁCH BÀI HÁT
  static async findAllSong(
    limit: number,
    offset: number
  ): Promise<SongWithArtists[]> {

    const sql = `
      SELECT 
        s.song_id,
        s.title,
        s.album_id,
        s.genre_id,
        s.file_url,
        s.file_public_id,
        s.cover_url,
        s.cover_public_id,
        s.is_active,
        a.artist_id,
        a.name AS artist_name
      FROM ( SELECT * FROM songs s ORDER BY s.song_id DESC LIMIT ? OFFSET ? ) AS s
      LEFT JOIN song_artists sa ON sa.song_id = s.song_id
      LEFT JOIN artists a ON a.artist_id = sa.artist_id
      ORDER BY s.song_id DESC;
    `;
// Thực hiện query
    const [rows] = await pool.query<any[]>(sql, [limit, offset]);
// Map để gom artists theo song_id
    const map = new Map<number, SongWithArtists>();

    for (const row of rows) {
      // Nếu song chưa có trong map, tạo mới
      if (!map.has(row.song_id)) {
        map.set(row.song_id, {
          song_id: row.song_id,
          title: row.title,
          album_id: row.album_id,
          genre_id: row.genre_id,
          file_url: row.file_url,
          file_public_id: row.file_public_id,
          cover_url: row.cover_url,
          cover_public_id: row.cover_public_id,
          is_active: row.is_active,
          artists: []
        });
      }
        // Lấy song từ map
      const song = map.get(row.song_id);
      if (song && row.artist_id) {
        const artist: Artist = {
          artist_id: row.artist_id,
          name: row.artist_name
        };
         song.artists!.push(artist)
      }
    }

    return Array.from(map.values());
  }
// LẤY DANH SÁCH BÀI HÁT CHO SELECT
static async findSongsForSelect() {
  const sql = `
    SELECT 
      song_id,
      title,
      album_id
    FROM songs
    ORDER BY title ASC
  `;

  const [rows] = await pool.query<any[]>(sql);
  return rows;
}

  // LẤY TỔNG BÁI HÁT
  static async countSongs(): Promise<number> {
  const [rows]: any = await pool.query(
    `SELECT COUNT(*) as total FROM songs`
  );
  return rows[0].total;
}

  // LẤY CHI TIẾT BÀI HÁT THEO ID
  static async findSongById(song_id: number, includeDetails = false): Promise<SongWithArtists | null> {
  const sql = `
    SELECT s.song_id, s.title, s.genre_id, s.duration, s.lyrics, s.file_url, s.file_public_id, s.cover_url, s.cover_public_id, s.is_active, a.artist_id, a.name AS artist_name
    FROM songs s
    LEFT JOIN song_artists sa ON sa.song_id = s.song_id
    LEFT JOIN artists a ON a.artist_id = sa.artist_id
    WHERE s.song_id = ?
  `;

  const [rows] = await pool.query<any[]>(sql, [song_id]);

  if (!rows.length) return null;

  let song: SongWithArtists | null = null;

  for (const row of rows) {
    // Khởi tạo song 1 lần
    if (!song) {
      song = {
        song_id: row.song_id,
        title: row.title,
        genre_id: row.genre_id,
        duration: row.duration,
        lyrics: row.lyrics,
        file_url: row.file_url,
        file_public_id: row.file_public_id,
        cover_public_id: row.cover_public_id,
        cover_url: row.cover_url,
        is_active: row.is_active,
        artists: [],
      };
    }

    // Push artist nếu tồn tại
    if (row.artist_id) {
      song.artists!.push({
        artist_id: row.artist_id,
        name: row.artist_name,
        avatar_url: row.avatar_url,
      });
    }
  }

  return song;
}

// XOÁ BÀI HÁT THEO ID
static async deleteSongById(song_id: number): Promise<boolean> {
  const connection = await pool.getConnection(); // lấy connection để chạy transaction
  try {
    await connection.beginTransaction();

    // Lấy public_id trước
    const [rows]: any = await connection.query(
      `SELECT file_public_id, cover_public_id FROM songs WHERE song_id = ?`,
      [song_id]
    );
     if (!rows.length) return false;

    const { file_public_id, cover_public_id } = rows[0];

    //  Xoá các liên kết trong song_artists
    await connection.query('DELETE FROM song_artists WHERE song_id = ?', [song_id]);

    //  Xoá bài hát trong songs
    const [result]: any = await connection.query('DELETE FROM songs WHERE song_id = ?', [song_id]);

    await connection.commit(); // commit transaction

    // Xoá Cloudinary (sau commit)
    if (file_public_id) {
      await deleteFromCloudinary(file_public_id, "video");
    }

    if (cover_public_id) {
      await deleteFromCloudinary(cover_public_id, "image");
    }

    return result.affectedRows > 0; // trả về true nếu xoá thành công
  } catch (error) {
    await connection.rollback(); // rollback nếu có lỗi
    console.error('Delete song error:', error);
    return false;
  } finally {
    connection.release();
  }
}
// TẠO MỚI BÀI HÁT
static async createSong(data: {
  title: string;
  genre_id: number;
  duration: number;
  lyrics?: string;
  artistIds: number[];
  file_url: string;
  file_public_id: string;
  cover_url?: string | null;
  cover_public_id?: string | null;
}) {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    // Insert song
    const [result]: any = await connection.query(
      `
      INSERT INTO songs (title, genre_id, duration, lyrics, file_url, file_public_id, cover_url, cover_public_id, release_date)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
      `,
      [
        data.title,
        data.genre_id,
        data.duration,
        data.lyrics ?? null,
        data.file_url,
        data.file_public_id,
        data.cover_url ?? null,
        data.cover_public_id ?? null,
      ]
    );

    const songId = result.insertId;

    // Insert song_artists
    for (const artistId of data.artistIds) {
      await connection.query(
        `INSERT INTO song_artists (song_id, artist_id) VALUES (?, ?)`,
        [songId, artistId]
      );
    }

    await connection.commit();

    return {
      song_id: songId,
      title: data.title,
      file_url: data.file_url,
      file_public_id: data.file_public_id,
      cover_url: data.cover_url,
      cover_public_id: data.cover_public_id,
    };
  } catch (error) {
    await connection.rollback();
    console.error("Create song repository error:", error);
    throw error;
  } finally {
    connection.release();
  }
}

// CẬP NHẬP BÀI HÁT THEO ID
static async updateSong(
  song_id: number,
  data: {
    title: string;
    genre_id: number;
    duration: number;
    lyrics?: string;
    is_active: boolean;
    artistIds: number[];
    file_url?: string;
    file_public_id?: string;
    cover_url?: string;
    cover_public_id?: string;
  }
) {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    // Update bảng songs
    await connection.query(
      `
      UPDATE songs
      SET
        title = ?,
        genre_id = ?,
        duration = ?,
        lyrics = ?,
        is_active = ?,
        file_url = COALESCE(?, file_url),
        file_public_id = COALESCE(?, file_public_id),
        cover_url = COALESCE(?, cover_url),
        cover_public_id = COALESCE(?, cover_public_id)
      WHERE song_id = ?
      `,
      [
        data.title,
        data.genre_id,
        data.duration,
        data.lyrics ?? null,
        data.is_active ? 1 : 0,
        data.file_url ?? null,
        data.file_public_id ?? null,
        data.cover_url ?? null,
        data.cover_public_id ?? null,
        song_id,
      ]
    );

    // Xoá artist cũ trong song_artists
    await connection.query(
      `DELETE FROM song_artists WHERE song_id = ?`,
      [song_id]
    );

    // Thêm artist mới vào song_artists
    for (const artistId of data.artistIds) {
      await connection.query(
        `INSERT INTO song_artists (song_id, artist_id) VALUES (?, ?)`,
        [song_id, artistId]
      );
    }

    await connection.commit();

    // Trả lại detail song
    return AdminSongRepository.findSongById(song_id);
  } catch (error) {
    await connection.rollback();
    console.error("Update song repository error:", error);
    throw error;
  } finally {
    connection.release();
  }
}

}
