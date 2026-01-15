import pool from "../config/database";
import { Song, SongWithArtists, Artist } from "../models";

export class SongRepository {
  // =========================
  // Helper: map rows -> SongWithArtists[]
  // =========================
  private static mapRowsToSongsWithArtists(rows: any[]): SongWithArtists[] {
    const map = new Map<number, SongWithArtists>();

    for (const row of rows) {
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

      // Nếu có artist
      if (row.artist_id) {
        map.get(row.song_id)!.artists!.push({
          artist_id: row.artist_id,
          name: row.artist_name,
          avatar_url: row.artist_avatar,
          description: row.artist_description ?? null,
          is_active: row.artist_is_active ?? 1,
        } as Artist);
      }
    }

    return Array.from(map.values());
  }

  // =========================
  // Tạo bài hát mới
  // =========================
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
    if (!created) throw new Error("Failed to create song");
    return created;
  }

  // =========================
  // Tìm bài hát theo ID (không artists)
  // =========================
  static async findById(songId: number): Promise<Song | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM songs WHERE song_id = ? AND is_active = 1",
      [songId]
    );
    const songs = rows as Song[];
    return songs[0] || null;
  }

  // =========================
  // Tìm 1 bài hát với artists
  // =========================
  static async findByIdWithArtists(songId: number): Promise<SongWithArtists | null> {
    const [rows] = await pool.execute(
      `
      SELECT 
        s.*,
        a.artist_id,
        a.name AS artist_name,
        a.avatar_url AS artist_avatar,
        a.description AS artist_description,
        a.is_active AS artist_is_active
      FROM songs s
      LEFT JOIN song_artists sa ON s.song_id = sa.song_id
      LEFT JOIN artists a ON sa.artist_id = a.artist_id AND a.is_active = 1
      WHERE s.song_id = ? AND s.is_active = 1
      `,
      [songId]
    );

    const list = this.mapRowsToSongsWithArtists(rows as any[]);
    return list[0] ?? null;
  }

  // =========================
  // Lấy danh sách bài hát (có artists)
  // =========================
  static async findAll(limit: number = 50, offset: number = 0): Promise<SongWithArtists[]> {
    const [rows] = await pool.execute(
      `
      SELECT 
        s.*,
        a.artist_id,
        a.name AS artist_name,
        a.avatar_url AS artist_avatar,
        a.description AS artist_description,
        a.is_active AS artist_is_active
      FROM songs s
      LEFT JOIN song_artists sa ON s.song_id = sa.song_id
      LEFT JOIN artists a ON sa.artist_id = a.artist_id AND a.is_active = 1
      WHERE s.is_active = 1
      ORDER BY s.song_id DESC
      LIMIT ? OFFSET ?
      `,
      [limit, offset]
    );

    return this.mapRowsToSongsWithArtists(rows as any[]);
  }

  // =========================
  // Tìm kiếm bài hát (CÓ artists)  ✅ FIX
  // =========================
  static async search(query: string, limit: number = 50, offset: number = 0): Promise<SongWithArtists[]> {
    const q = `%${query}%`;

    const [rows] = await pool.execute(
      `
      SELECT 
        s.*,
        a.artist_id,
        a.name AS artist_name,
        a.avatar_url AS artist_avatar,
        a.description AS artist_description,
        a.is_active AS artist_is_active
      FROM songs s
      LEFT JOIN song_artists sa ON s.song_id = sa.song_id
      LEFT JOIN artists a ON sa.artist_id = a.artist_id AND a.is_active = 1
      WHERE s.is_active = 1
        AND (s.title LIKE ? OR s.lyrics LIKE ?)
      ORDER BY s.song_id DESC
      LIMIT ? OFFSET ?
      `,
      [q, q, limit, offset]
    );

    return this.mapRowsToSongsWithArtists(rows as any[]);
  }

  // =========================
  // Lấy bài hát theo genre (CÓ artists) ✅ FIX
  // =========================
  static async findByGenre(
    genreId: number,
    limit: number = 50,
    offset: number = 0
  ): Promise<SongWithArtists[]> {
    const [rows] = await pool.execute(
      `
      SELECT 
        s.*,
        a.artist_id,
        a.name AS artist_name,
        a.avatar_url AS artist_avatar,
        a.description AS artist_description,
        a.is_active AS artist_is_active
      FROM songs s
      LEFT JOIN song_artists sa ON s.song_id = sa.song_id
      LEFT JOIN artists a ON sa.artist_id = a.artist_id AND a.is_active = 1
      WHERE s.genre_id = ? AND s.is_active = 1
      ORDER BY s.song_id DESC
      LIMIT ? OFFSET ?
      `,
      [genreId, limit, offset]
    );

    return this.mapRowsToSongsWithArtists(rows as any[]);
  }

  // =========================
  // Lấy danh sách bài hát theo artist (đã có artists) ✅ giữ
  // =========================
  static async findByArtist(
    artistId: number,
    limit: number = 50,
    offset: number = 0
  ): Promise<SongWithArtists[]> {
    const [rows] = await pool.execute(
      `
      SELECT 
        s.*,
        a.artist_id,
        a.name AS artist_name,
        a.avatar_url AS artist_avatar,
        a.description AS artist_description,
        a.is_active AS artist_is_active
      FROM songs s
      INNER JOIN song_artists sa ON s.song_id = sa.song_id
      INNER JOIN artists a ON sa.artist_id = a.artist_id
      WHERE sa.artist_id = ?
        AND s.is_active = 1
        AND a.is_active = 1
      ORDER BY s.song_id DESC
      LIMIT ? OFFSET ?
      `,
      [artistId, limit, offset]
    );

    return this.mapRowsToSongsWithArtists(rows as any[]);
  }

  // =========================
  // Lấy bài hát theo album (CÓ artists) ✅ FIX
  // =========================
  static async findByAlbum(albumId: number, limit: number = 50, offset: number = 0): Promise<SongWithArtists[]> {
    const [rows] = await pool.execute(
      `
      SELECT 
        s.*,
        a.artist_id,
        a.name AS artist_name,
        a.avatar_url AS artist_avatar,
        a.description AS artist_description,
        a.is_active AS artist_is_active
      FROM songs s
      LEFT JOIN song_artists sa ON s.song_id = sa.song_id
      LEFT JOIN artists a ON sa.artist_id = a.artist_id AND a.is_active = 1
      WHERE s.album_id = ? AND s.is_active = 1
      ORDER BY s.song_id DESC
      LIMIT ? OFFSET ?
      `,
      [albumId, limit, offset]
    );

    return this.mapRowsToSongsWithArtists(rows as any[]);
  }

  // =========================
  // Thêm artist vào bài hát
  // =========================
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

  // =========================
  // Xóa artist khỏi bài hát
  // =========================
  static async removeArtist(songId: number, artistId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM song_artists WHERE song_id = ? AND artist_id = ?",
      [songId, artistId]
    );
    return (result as any).affectedRows > 0;
  }

  // =========================
  // Cập nhật bài hát
  // =========================
  static async update(songId: number, updates: Partial<Song>): Promise<Song | null> {
    const fields: string[] = [];
    const values: any[] = [];

    Object.keys(updates).forEach((key) => {
      if (updates[key as keyof Song] !== undefined && key !== "song_id") {
        fields.push(`${key} = ?`);
        values.push(updates[key as keyof Song]);
      }
    });

    if (fields.length === 0) return this.findById(songId);

    values.push(songId);
    await pool.execute(`UPDATE songs SET ${fields.join(", ")} WHERE song_id = ?`, values);

    return this.findById(songId);
  }

  // =========================
  // Xóa bài hát (soft delete)
  // =========================
  static async delete(songId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "UPDATE songs SET is_active = 0 WHERE song_id = ?",
      [songId]
    );
    return (result as any).affectedRows > 0;
  }

  static async findByIdWithFullInfo(songId: number): Promise<any | null> {
  const [rows] = await pool.execute(
    `
    SELECT 
      s.*,

      a.artist_id,
      a.name AS artist_name,
      a.avatar_url AS artist_avatar,

      al.album_id,
      al.name AS album_name,

      g.genre_id,
      g.name AS genre_name

    FROM songs s
    LEFT JOIN song_artists sa ON s.song_id = sa.song_id
    LEFT JOIN artists a ON sa.artist_id = a.artist_id AND a.is_active = 1

    LEFT JOIN albums al ON s.album_id = al.album_id
    LEFT JOIN genres g ON s.genre_id = g.genre_id

    WHERE s.song_id = ? AND s.is_active = 1
    `,
    [songId]
  );

  const list = this.mapRowsToSongsWithArtists(rows as any[]);
  return list[0] ?? null;
}

}