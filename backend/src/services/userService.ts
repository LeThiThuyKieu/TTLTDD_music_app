import { UserModel } from "../models/User";
import { User } from "../types";

export class UserService {
  // Lấy user theo Firebase UID
  static async getUserByFirebaseUid(firebaseUid: string): Promise<User | null> {
    return await UserModel.findByFirebaseUid(firebaseUid);
  }

  // Lấy user theo ID
  static async getUserById(userId: number): Promise<User | null> {
    return await UserModel.findById(userId);
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

    return await UserModel.update(userId, updateData);
  }
}
