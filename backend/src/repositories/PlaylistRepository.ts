import pool from "../config/database";
import { Playlist, Song } from "../models";

export class PlaylistRepository {
  // Tạo playlist mới
  static async create(playlist: Playlist): Promise<Playlist> {
    const [result] = await pool.execute(
      "INSERT INTO playlists (user_id, name, cover_url, is_public) VALUES (?, ?, ?, ?)",
      [
        playlist.user_id,
        playlist.name,
        playlist.cover_url || null,
        playlist.is_public ?? 0,
      ]
    );
    const insertId = (result as any).insertId;
    const created = await this.findById(insertId);
    if (!created) {
      throw new Error("Failed to create playlist");
    }
    return created;
  }

  // Tìm playlist theo ID
  static async findById(playlistId: number): Promise<Playlist | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM playlists WHERE playlist_id = ?",
      [playlistId]
    );
    const playlists = rows as Playlist[];
    return playlists[0] || null;
  }

  // Lấy playlists của user
  static async findByUserId(userId: number): Promise<Playlist[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM playlists WHERE user_id = ? ORDER BY created_at DESC",
      [userId]
    );
    return rows as Playlist[];
  }

  // Lấy playlists public
  static async findPublic(
    limit: number = 50,
    offset: number = 0
  ): Promise<Playlist[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM playlists WHERE is_public = 1 ORDER BY created_at DESC LIMIT ? OFFSET ?",
      [limit, offset]
    );
    return rows as Playlist[];
  }

  // Thêm bài hát vào playlist
  static async addSong(playlistId: number, songId: number): Promise<boolean> {
    try {
      await pool.execute(
        "INSERT INTO playlist_songs (playlist_id, song_id) VALUES (?, ?)",
        [playlistId, songId]
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  // Xóa bài hát khỏi playlist
  static async removeSong(
    playlistId: number,
    songId: number
  ): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM playlist_songs WHERE playlist_id = ? AND song_id = ?",
      [playlistId, songId]
    );
    return (result as any).affectedRows > 0;
  }

  // Lấy danh sách bài hát trong playlist
  static async getSongs(playlistId: number): Promise<Song[]> {
    const [rows] = await pool.execute(
      `SELECT s.* FROM songs s
       INNER JOIN playlist_songs ps ON s.song_id = ps.song_id
       WHERE ps.playlist_id = ? AND s.is_active = 1
       ORDER BY ps.playlist_id`,
      [playlistId]
    );
    return rows as Song[];
  }

  // Cập nhật playlist
  static async update(
    playlistId: number,
    updates: Partial<Playlist>
  ): Promise<Playlist | null> {
    const fields: string[] = [];
    const values: any[] = [];

    Object.keys(updates).forEach((key) => {
      if (
        updates[key as keyof Playlist] !== undefined &&
        key !== "playlist_id" &&
        key !== "user_id" &&
        key !== "created_at"
      ) {
        fields.push(`${key} = ?`);
        values.push(updates[key as keyof Playlist]);
      }
    });

    if (fields.length === 0) {
      return this.findById(playlistId);
    }

    values.push(playlistId);
    await pool.execute(
      `UPDATE playlists SET ${fields.join(", ")} WHERE playlist_id = ?`,
      values
    );

    return this.findById(playlistId);
  }

  // Xóa playlist
  static async delete(playlistId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM playlists WHERE playlist_id = ?",
      [playlistId]
    );
    return (result as any).affectedRows > 0;
  }
}
