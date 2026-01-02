import { UserRepository } from "../repositories/UserRepository";
import { User } from "../models";
import bcrypt from "bcryptjs";

export class UserService {
  // Lấy user theo ID
  static async getUserById(userId: number): Promise<User | null> {
    const user = await UserRepository.findById(userId);
    if (!user) return null;

    // Không trả về password_hash
    const { password_hash: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  // Đổi mật khẩu khi đã login
  static async changePassword(
    userId: number,
    oldPassword: string,
    newPassword: string
  ): Promise<void> {
    // Lấy user
    const user = await UserRepository.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // Check mật khẩu cũ, so sánh
    const isMatch = await bcrypt.compare(oldPassword, user.password_hash);
    if (!isMatch) {
      throw new Error("Mật khẩu hiện tại không đúng");
    }

    // Hash mật khẩu mới
    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    // Update DB
    await UserRepository.update(userId, {
      password_hash: newPasswordHash,
    });
  }

  // Cập nhật profile (chỉ name)
  static async updateNameProfile(
    userId: number,
    updates: { name?: string }
  ): Promise<User | null> {
    const updateData: Partial<User> = {};

    if (updates.name !== undefined) {
      updateData.name = updates.name;
    }

    const updated = await UserRepository.update(userId, updateData);
    if (!updated) return null;

    // Không trả về password_hash
    const { password_hash: _, ...userWithoutPassword } = updated;
    return userWithoutPassword as User;
  }
}
