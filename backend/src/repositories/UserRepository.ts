import pool from "../config/database";
import { User } from "../models";

export class UserRepository {
  // Tạo user mới
  static async create(user: User): Promise<User> {
    const [result] = await pool.execute(
      "INSERT INTO users (firebase_uid, name, email, avatar_url) VALUES (?, ?, ?, ?)",
      [user.firebase_uid, user.name, user.email, user.avatar_url || null]
    );
    const insertId = (result as any).insertId;
    const created = await this.findById(insertId);
    if (!created) {
      throw new Error("Failed to create user");
    }
    return created;
  }

  // Tìm user theo ID
  static async findById(userId: number): Promise<User | null> {
    const [rows] = await pool.execute("SELECT * FROM users WHERE user_id = ?", [
      userId,
    ]);
    const users = rows as User[];
    return users[0] || null;
  }

  // Tìm user theo Firebase UID
  static async findByFirebaseUid(firebaseUid: string): Promise<User | null> {
    const [rows] = await pool.execute(
      "SELECT * FROM users WHERE firebase_uid = ?",
      [firebaseUid]
    );
    const users = rows as User[];
    return users[0] || null;
  }

  // Tìm user theo email
  static async findByEmail(email: string): Promise<User | null> {
    const [rows] = await pool.execute("SELECT * FROM users WHERE email = ?", [
      email,
    ]);
    const users = rows as User[];
    return users[0] || null;
  }

  // Cập nhật user
  static async update(
    userId: number,
    updates: Partial<User>
  ): Promise<User | null> {
    const fields: string[] = [];
    const values: any[] = [];

    if (updates.name) {
      fields.push("name = ?");
      values.push(updates.name);
    }
    if (updates.avatar_url !== undefined) {
      fields.push("avatar_url = ?");
      values.push(updates.avatar_url);
    }

    if (fields.length === 0) {
      return this.findById(userId);
    }

    values.push(userId);
    await pool.execute(
      `UPDATE users SET ${fields.join(", ")} WHERE user_id = ?`,
      values
    );

    return this.findById(userId);
  }

  // Xóa user
  static async delete(userId: number): Promise<boolean> {
    const [result] = await pool.execute("DELETE FROM users WHERE user_id = ?", [
      userId,
    ]);
    return (result as any).affectedRows > 0;
  }
}
