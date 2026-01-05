import pool from "../config/database";
import { Artist } from "../models";

export class ArtistRepository {
  // Tạo artist mới
  static async create(artist: Artist): Promise<Artist> {
    const [result] = await pool.execute(
      "INSERT INTO artists (name, avatar_url, description, is_active) VALUES (?, ?, ?, ?)",
      [
        artist.name,
        artist.avatar_url || null,
        artist.description || null,
        artist.is_active ?? 1,
      ]
    );
    const insertId = (result as any).insertId;
    const created = await this.findById(insertId);
    if (!created) {
      throw new Error("Failed to create artist");
    }
    return created;
  }

  // Tìm artist theo ID
  static async findById(artistId: number): Promise<Artist | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM artists WHERE artist_id = ? AND is_active = 1",
      [artistId]
    );
    const artists = rows as Artist[];
    return artists[0] || null;
  }

  // Lấy danh sách artists
  static async findAll(
    limit: number = 50,
    offset: number = 0
  ): Promise<Artist[]> {
    const [rows] = await pool.execute(
      "SELECT * FROM artists WHERE is_active = 1 ORDER BY name LIMIT ? OFFSET ?",
      [limit, offset]
    );
    return rows as Artist[];
  }

  // Tìm kiếm artist
  static async search(query: string, limit: number = 50): Promise<Artist[]> {
    const [rows] = await pool.execute(
      `SELECT * FROM artists 
       WHERE name LIKE ? AND is_active = 1
       ORDER BY name LIMIT ?`,
      [`%${query}%`, limit]
    );
    return rows as Artist[];
  }

  // Cập nhật artist
  static async update(
    artistId: number,
    updates: Partial<Artist>
  ): Promise<Artist | null> {
    const fields: string[] = [];
    const values: any[] = [];

    Object.keys(updates).forEach((key) => {
      if (updates[key as keyof Artist] !== undefined && key !== "artist_id") {
        fields.push(`${key} = ?`);
        values.push(updates[key as keyof Artist]);
      }
    });

    if (fields.length === 0) {
      return this.findById(artistId);
    }

    values.push(artistId);
    await pool.execute(
      `UPDATE artists SET ${fields.join(", ")} WHERE artist_id = ?`,
      values
    );

    return this.findById(artistId);
  }

  // Xóa artist (soft delete)
  static async delete(artistId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "UPDATE artists SET is_active = 0 WHERE artist_id = ?",
      [artistId]
    );
    return (result as any).affectedRows > 0;
  }
}
