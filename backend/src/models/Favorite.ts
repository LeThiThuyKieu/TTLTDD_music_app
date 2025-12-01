import pool from "../config/database";
import { Song } from "../types";

export class FavoriteModel {
  // Thêm vào favorites
  static async add(userId: number, songId: number): Promise<boolean> {
    try {
      await pool.execute(
        "INSERT INTO favorites (user_id, song_id) VALUES (?, ?)",
        [userId, songId]
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  // Xóa khỏi favorites
  static async remove(userId: number, songId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM favorites WHERE user_id = ? AND song_id = ?",
      [userId, songId]
    );
    return (result as any).affectedRows > 0;
  }

  // Kiểm tra có trong favorites không
  static async isFavorite(userId: number, songId: number): Promise<boolean> {
    const [rows] = await pool.execute(
      "SELECT * FROM favorites WHERE user_id = ? AND song_id = ?",
      [userId, songId]
    );
    return (rows as any[]).length > 0;
  }

  // Lấy danh sách favorites của user
  static async findByUserId(userId: number): Promise<Song[]> {
    const [rows] = await pool.execute(
      `SELECT s.* FROM songs s
       INNER JOIN favorites f 
       ON s.song_id = f.song_id
       WHERE f.user_id = ? AND s.is_active = 1
       ORDER BY f.user_id DESC`,
      [userId]
    );
    return rows as Song[];
  }
}
