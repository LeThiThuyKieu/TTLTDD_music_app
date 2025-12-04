import { FavoriteModel } from "../models/Favorite";
import { UserModel } from "../models/User";
import { Song } from "../types";

export class FavoriteService {
  // Lấy user từ Firebase UID
  private static async getUserByFirebaseUid(
    firebaseUid: string
  ): Promise<{ user_id: number } | null> {
    const user = await UserModel.findByFirebaseUid(firebaseUid);
    if (!user || !user.user_id) return null;
    return { user_id: user.user_id };
  }

  // Thêm vào favorites
  static async addFavorite(
    firebaseUid: string,
    songId: number
  ): Promise<boolean> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return false;

    return await FavoriteModel.add(user.user_id, songId);
  }

  // Xóa khỏi favorites
  static async removeFavorite(
    firebaseUid: string,
    songId: number
  ): Promise<boolean> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return false;

    return await FavoriteModel.remove(user.user_id, songId);
  }

  // Lấy danh sách favorites
  static async getFavorites(firebaseUid: string): Promise<Song[]> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return [];

    return await FavoriteModel.findByUserId(user.user_id);
  }

  // Kiểm tra có trong favorites không
  static async isFavorite(
    firebaseUid: string,
    songId: number
  ): Promise<boolean> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return false;

    return await FavoriteModel.isFavorite(user.user_id, songId);
  }
}
