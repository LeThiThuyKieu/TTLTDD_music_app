import pool from "../config/database";
import { Album, Song } from "../types";

export class AlbumModel {
  // Tạo album mới
  static async create(album: Album): Promise<Album> {
    const [result] = await pool.execute(
      "INSERT INTO albums (title, artist_id, cover_url, release_date, is_active) VALUES (?, ?, ?, ?, ?)",
      [
        album.title,
        album.artist_id || null,
        album.cover_url || null,
        album.release_date || null,
        album.is_active ?? 1,
      ]
    );
    const insertId = (result as any).insertId;
    const created = await this.findById(insertId);
    if (!created) {
      throw new Error("Failed to create album");
    }
    return created;
  }

  // Tìm album theo ID
  static async findById(albumId: number): Promise<Album | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM albums WHERE album_id = ? AND is_active = 1",
      [albumId]
    );
    const albums = rows as Album[];
    return albums[0] || null;
  }

  // Lấy danh sách albums
  static async findAll(
    limit: number = 50,
    offset: number = 0
  ): Promise<Album[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM albums WHERE is_active = 1 ORDER BY album_id DESC LIMIT ? OFFSET ?",
      [limit, offset]
    );
    return rows as Album[];
  }

  // Lấy albums theo artist
  static async findByArtist(artistId: number): Promise<Album[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM albums WHERE artist_id = ? AND is_active = 1 ORDER BY release_date DESC",
      [artistId]
    );
    return rows as Album[];
  }

  // Lấy danh sách bài hát trong album
  static async getSongs(albumId: number): Promise<Song[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM songs WHERE album_id = ? AND is_active = 1 ORDER BY song_id",
      [albumId]
    );
    return rows as Song[];
  }

  // Cập nhật album
  static async update(
    albumId: number,
    updates: Partial<Album>
  ): Promise<Album | null> {
    const fields: string[] = [];
    const values: any[] = [];

    Object.keys(updates).forEach((key) => {
      if (updates[key as keyof Album] !== undefined && key !== "album_id") {
        fields.push(`${key} = ?`);
        values.push(updates[key as keyof Album]);
      }
    });

    if (fields.length === 0) {
      return this.findById(albumId);
    }

    values.push(albumId);
    await pool.execute(
      `UPDATE albums SET ${fields.join(", ")} WHERE album_id = ?`,
      values
    );

    return this.findById(albumId);
  }

  // Xóa album (soft delete)
  static async delete(albumId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "UPDATE albums SET is_active = 0 WHERE album_id = ?",
      [albumId]
    );
    return (result as any).affectedRows > 0;
  }
}
