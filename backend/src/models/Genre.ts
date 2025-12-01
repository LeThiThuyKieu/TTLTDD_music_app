import pool from "../config/database";
import { Genre } from "../types";

export class GenreModel {
  // Tạo genre mới
  static async create(genre: Genre): Promise<Genre> {
    const [result] = await pool.execute(
      "INSERT INTO genres (name) VALUES (?)",
      [genre.name]
    );
    const insertId = (result as any).insertId;
    const created = await this.findById(insertId);
    if (!created) {
      throw new Error("Failed to create genre");
    }
    return created;
  }

  // Tìm genre theo ID
  static async findById(genreId: number): Promise<Genre | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM genres WHERE genre_id = ?",
      [genreId]
    );
    const genres = rows as Genre[];
    return genres[0] || null;
  }

  // Lấy danh sách genres
  static async findAll(): Promise<Genre[]> {
    const [rows] = await pool.execute("SELECT * FROM genres ORDER BY name");
    return rows as Genre[];
  }

  // Cập nhật genre
  static async update(
    genreId: number,
    updates: Partial<Genre>
  ): Promise<Genre | null> {
    const fields: string[] = [];
    const values: any[] = [];

    if (updates.name) {
      fields.push("name = ?");
      values.push(updates.name);
    }

    if (fields.length === 0) {
      return this.findById(genreId);
    }

    values.push(genreId);
    await pool.execute(
      `UPDATE genres SET ${fields.join(", ")} WHERE genre_id = ?`,
      values
    );

    return this.findById(genreId);
  }

  // Xóa genre
  static async delete(genreId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM genres WHERE genre_id = ?",
      [genreId]
    );
    return (result as any).affectedRows > 0;
  }
}
