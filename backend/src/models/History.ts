import pool from "../config/database";
import { History, Song } from "../types";

export class HistoryModel {
  // Thêm vào history
  static async create(history: History): Promise<History> {
    const [result] = await pool.execute(
      "INSERT INTO history (user_id, song_id, listened_duration) VALUES (?, ?, ?)",
      [history.user_id, history.song_id, history.listened_duration || 0]
    );
    const insertId = (result as any).insertId;
    const created = await this.findById(insertId);
    if (!created) {
      throw new Error("Failed to create history");
    }
    return created;
  }

  // Tìm history theo ID
  static async findById(historyId: number): Promise<History | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM history WHERE history_id = ?",
      [historyId]
    );
    const histories = rows as History[];
    return histories[0] || null;
  }

  // Lấy lịch sử nghe của user
  static async findByUserId(
    userId: number,
    limit: number = 50
  ): Promise<Song[]> {
    const [rows] = await pool.execute(
      `SELECT DISTINCT s.*, h.listened_at, h.listened_duration 
       FROM songs s
       INNER JOIN history h ON s.song_id = h.song_id
       WHERE h.user_id = ? AND s.is_active = 1
       ORDER BY h.listened_at DESC
       LIMIT ?`,
      [userId, limit]
    );
    return rows as Song[];
  }

  // Xóa lịch sử của user
  static async deleteByUserId(userId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM history WHERE user_id = ?",
      [userId]
    );
    return (result as any).affectedRows > 0;
  }

  // Xóa một bản ghi history
  static async delete(historyId: number): Promise<boolean> {
    const [result] = await pool.execute(
      "DELETE FROM history WHERE history_id = ?",
      [historyId]
    );
    return (result as any).affectedRows > 0;
  }
}
