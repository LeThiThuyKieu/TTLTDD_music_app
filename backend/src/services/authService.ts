import { UserRepository } from "../repositories/UserRepository";
import { firebaseAuth } from "../config/firebase";
import { User } from "../models";

export class AuthService {
  // Đồng bộ user từ Firebase vào DB
  static async syncUser(
    firebaseUid: string,
    email: string | undefined,
    name?: string,
    avatar_url?: string
  ): Promise<User> {
    // Lấy thông tin từ Firebase
    const firebaseUser = await firebaseAuth.getUser(firebaseUid);

    // Kiểm tra user đã tồn tại chưa
    let user = await UserRepository.findByFirebaseUid(firebaseUid);

    if (user) {
      // Cập nhật thông tin nếu có thay đổi
      const updates: any = {};
      if (name) updates.name = name;
      if (avatar_url !== undefined) updates.avatar_url = avatar_url;
      if (firebaseUser.email && firebaseUser.email !== user.email) {
        updates.email = firebaseUser.email;
      }

      if (Object.keys(updates).length > 0) {
        user = await UserRepository.update(user.user_id!, updates);
      }
    } else {
      // Tạo user mới
      user = await UserRepository.create({
        firebase_uid: firebaseUid,
        name: name || firebaseUser.displayName || "User",
        email: email || firebaseUser.email || "",
        avatar_url: avatar_url || firebaseUser.photoURL || undefined,
      });
    }

    if (!user) {
      throw new Error("Failed to sync user");
    }

    return user;
  }

  // Lấy thông tin user hiện tại
  static async getCurrentUser(firebaseUid: string): Promise<User | null> {
    return await UserRepository.findByFirebaseUid(firebaseUid);
  }
}
