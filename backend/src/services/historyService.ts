import { HistoryRepository } from "../repositories/HistoryRepository";
import { History, Song } from "../models";

export class HistoryService {
  // Thêm vào history
  static async addHistory(
    userId: number,
    songId: number,
    listenedDuration: number = 0
  ): Promise<History> {
    return await HistoryRepository.create({
      user_id: userId,
      song_id: songId,
      listened_duration: listenedDuration,
    });
  }

  // Lấy lịch sử nghe
  static async getHistory(userId: number, limit: number = 50): Promise<Song[]> {
    return await HistoryRepository.findByUserId(userId, limit);
  }

  // Xóa lịch sử
  static async clearHistory(userId: number): Promise<boolean> {
    return await HistoryRepository.deleteByUserId(userId);
  }
}
