import { HistoryModel } from "../models/History";
import { UserModel } from "../models/User";
import { History, Song } from "../types";

export class HistoryService {
  // Lấy user từ Firebase UID
  private static async getUserByFirebaseUid(
    firebaseUid: string
  ): Promise<{ user_id: number } | null> {
    const user = await UserModel.findByFirebaseUid(firebaseUid);
    if (!user || !user.user_id) return null;
    return { user_id: user.user_id };
  }

  // Thêm vào history
  static async addHistory(
    firebaseUid: string,
    songId: number,
    listenedDuration: number = 0
  ): Promise<History> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) {
      throw new Error("User not found");
    }

    return await HistoryModel.create({
      user_id: user.user_id,
      song_id: songId,
      listened_duration: listenedDuration,
    });
  }

  // Lấy lịch sử nghe
  static async getHistory(
    firebaseUid: string,
    limit: number = 50
  ): Promise<Song[]> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return [];

    return await HistoryModel.findByUserId(user.user_id, limit);
  }

  // Xóa lịch sử
  static async clearHistory(firebaseUid: string): Promise<boolean> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return false;

    return await HistoryModel.deleteByUserId(user.user_id);
  }
}
