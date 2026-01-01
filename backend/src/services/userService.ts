import { UserRepository } from "../repositories/UserRepository";
import { User } from "../models";

export class UserService {
  // Lấy user theo ID
  static async getUserById(userId: number): Promise<User | null> {
    const user = await UserRepository.findById(userId);
    if (!user) return null;

    // Không trả về password_hash
    const { password_hash: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  // Cập nhật profile
  static async updateProfile(
    userId: number,
    updates: { name?: string; avatar_url?: string | null }
  ): Promise<User | null> {
    const updateData: any = {};
    if (updates.name) updateData.name = updates.name;
    if (updates.avatar_url !== undefined)
      updateData.avatar_url = updates.avatar_url;

    const updated = await UserRepository.update(userId, updateData);
    if (!updated) return null;

    // Không trả về password_hash
    const { password_hash: _, ...userWithoutPassword } = updated;
    return userWithoutPassword as User;
  }
}
