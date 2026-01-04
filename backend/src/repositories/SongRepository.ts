import pool from "../config/database";
import { Song, SongWithArtists, Artist } from "../models";

export class SongRepository {
  // Tạo bài hát mới
  static async create(song: Song): Promise<Song> {
    const [result] = await pool.execute(
      `INSERT INTO songs (title, album_id, genre_id, duration, lyrics, file_url, cover_url, release_date, is_active)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        song.title,
        song.album_id || null,
        song.genre_id || null,
        song.duration || null,
        song.lyrics || null,
        song.file_url,
        song.cover_url || null,
        song.release_date || null,
        song.is_active ?? 1,
      ]
    );
    const insertId = (result as any).insertId;
    const created = await this.findById(insertId);
    if (!created) {
      throw new Error("Failed to create song");
    }
    return created;
  }

  // Tìm bài hát theo ID
  static async findById(songId: number): Promise<Song | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM songs WHERE song_id = ? AND is_active = 1",
      [songId]
    );
    const songs = rows as Song[];
    return songs[0] || null;
  }

  // Tìm bài hát với artists
  static async findByIdWithArtists(
    songId: number
  ): Promise<SongWithArtists | null> {
    const song = await this.findById(songId);
    if (!song) return null;

    const [artistRows] = await pool.execute(
      `SELECT a.* FROM artists a
       INNER JOIN song_artists sa ON a.artist_id = sa.artist_id
       WHERE sa.song_id = ? AND a.is_active = 1`,
      [songId]
    );

    return {
      ...song,
      artists: artistRows as Artist[],
    };
  }

  // Lấy danh sách bài hát
  static async findAll(
    limit: number = 50,
    offset: number = 0
  ): Promise<SongWithArtists[]> {
    const [rows] = await pool.execute(
      `
    SELECT 
      s.*,
      a.artist_id,
      a.name AS artist_name,
      a.avatar_url AS artist_avatar
    FROM songs s
    LEFT JOIN song_artists sa ON s.song_id = sa.song_id
    LEFT JOIN artists a ON sa.artist_id = a.artist_id AND a.is_active = 1
    WHERE s.is_active = 1
    ORDER BY s.song_id DESC
    LIMIT ? OFFSET ?
    `,
      [limit, offset]
    );

    const map = new Map<number, SongWithArtists>();

    for (const row of rows as any[]) {
      if (!map.has(row.song_id)) {
        map.set(row.song_id, {
          song_id: row.song_id,
          title: row.title,
          album_id: row.album_id,
          genre_id: row.genre_id,
          duration: row.duration,
          lyrics: row.lyrics,
          file_url: row.file_url,
          cover_url: row.cover_url,
          release_date: row.release_date,
          is_active: row.is_active,
          artists: [],
        });
      }

      if (row.artist_id) {
        map.get(row.song_id)!.artists!.push({
          artist_id: row.artist_id,
          name: row.artist_name,
          avatar_url: row.artist_avatar,
        });
      }
    }

    return Array.from(map.values());
  }

  // Tìm kiếm bài hát
  static async search(query: string, limit: number = 50): Promise<Song[]> {
    const [rows] = await pool.execute(
      `SELECT * FROM songs 
       WHERE (title LIKE ? OR title LIKE ?) AND is_active = 1 
       ORDER BY song_id DESC LIMIT ?`,
      [`%${query}%`, `%${query}%`, limit]
    );
    return rows as Song[];
  }

  // Lấy bài hát theo genre
  static async findByGenre(
    genreId: number,
    limit: number = 50,
    offset: number = 0
  ): Promise<Song[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM songs WHERE genre_id = ? AND is_active = 1 ORDER BY song_id DESC LIMIT ? OFFSET ?",
      [genreId, limit, offset]
    );
    return rows as Song[];
  }

  // Lấy bài hát theo album
  static async findByAlbum(albumId: number): Promise<Song[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM songs WHERE album_id = ? AND is_active = 1 ORDER BY song_id",
      [albumId]
    );
    return rows as Song[];
  }

  // Thêm artist vào bài hát
  static async addArtist(songId: number, artistId: number): Promise<boolean> {
    try {
      await pool.execute(
        "INSERT INTO song_artists (song_id, artist_id) VALUES (?, ?)",
        [songId, artistId]
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  // Xóa artist khỏi bài hát
  static async removeArtist(
    songId: number,
    artistId: number
  ): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM song_artists WHERE song_id = ? AND artist_id = ?",
      [songId, artistId]
    );
    return (result as any).affectedRows > 0;
  }

  // Cập nhật bài hát
  static async update(
    songId: number,
    updates: Partial<Song>
  ): Promise<Song | null> {
    const fields: string[] = [];
    const values: any[] = [];

    Object.keys(updates).forEach((key) => {
      if (updates[key as keyof Song] !== undefined && key !== "song_id") {
        fields.push(`${key} = ?`);
        values.push(updates[key as keyof Song]);
      }
    });

    if (fields.length === 0) {
      return this.findById(songId);
    }

    values.push(songId);
    await pool.execute(
      `UPDATE songs SET ${fields.join(", ")} WHERE song_id = ?`,
      values
    );

    return this.findById(songId);
  }

  // Xóa bài hát (soft delete)
  static async delete(songId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "UPDATE songs SET is_active = 0 WHERE song_id = ?",
      [songId]
    );
    return (result as any).affectedRows > 0;
  }
}
