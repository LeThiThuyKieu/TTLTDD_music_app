import pool from "../../config/database";
import { UserSummary } from "../../models";

export class AdminUserRepository {
    static async findAllUsers(
        limit: number,
        offset: number
    ): Promise<UserSummary[]> {
    const sql = `
        SELECT user_id, name, email, avatar_url, role, is_active
        FROM users
        ORDER BY user_id DESC
        LIMIT ? OFFSET ?;
    `;
    // thực hiện sql
        const [rows] = await pool.query<any[]>(sql, [limit, offset]);
        // Map dữ liệu DB về kiểu User
        const users: UserSummary[] = rows.map(row => ({
          user_id: row.user_id,
          name: row.name,
          email: row.email,
          avatar_url: row.avatar_url ?? undefined,
          role: row.role ?? undefined,
          is_active: row.is_active ?? 0
        }));
        return users;
    }
    // TÌM USER THEO ID
    static async findById(userId: number): Promise<any | null> {
  const [rows]: any = await pool.query(
    `SELECT user_id, role, is_active FROM users WHERE user_id = ?`,
    [userId]
  );
  return rows.length ? rows[0] : null;
}

    // KHOÁ TÀI KHOẢN THEO ID
    static async updateStatus(userId: number, isActive: number): Promise<boolean> {
  const [result]: any = await pool.query(
    `UPDATE users SET is_active = ? WHERE user_id = ?`,
    [isActive, userId]
  );
  return result.affectedRows > 0;
}


}