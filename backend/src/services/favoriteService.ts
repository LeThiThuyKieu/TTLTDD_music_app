// import { FavoriteRepository } from "../repositories/FavoriteRepository";
// import { Song } from "../models";

// export class FavoriteService {
//   // Thêm vào favorites
//   static async addFavorite(userId: number, songId: number): Promise<boolean> {
//     return await FavoriteRepository.add(userId, songId);
//   }

//   // Xóa khỏi favorites
//   static async removeFavorite(
//     userId: number,
//     songId: number
//   ): Promise<boolean> {
//     return await FavoriteRepository.remove(userId, songId);
//   }

//   // Lấy danh sách favorites
//   static async getFavorites(userId: number): Promise<Song[]> {
//     return await FavoriteRepository.findByUserId(userId);
//   }

//   // Kiểm tra có trong favorites không
//   static async isFavorite(userId: number, songId: number): Promise<boolean> {
//     return await FavoriteRepository.isFavorite(userId, songId);
//   }
// }
import { FavoriteRepository } from "../repositories/FavoriteRepository";
import { SongRepository } from "../repositories/SongRepository"; // cần có findById
import { Song } from "../models";

export class FavoriteService {
  /**
   * Thêm vào favorites (idempotent)
   * - Nếu song không tồn tại -> throw Error("Song not found")
   * - Nếu đã tồn tại trong favorites -> vẫn coi là success (true)
   */
  static async addFavorite(userId: number, songId: number): Promise<boolean> {
    this._validateIds(userId, songId);

    // 1) Check song tồn tại
    const song = await SongRepository.findById(songId);
    if (!song) {
      throw new Error("Song not found");
    }

    // 2) Nếu đã favorite -> success luôn (idempotent)
    const existed = await FavoriteRepository.isFavorite(userId, songId);
    if (existed) return true;

    // 3) Add
    const ok = await FavoriteRepository.add(userId, songId);
    if (!ok) {
      throw new Error("Failed to add to favorites");
    }
    return true;
  }

  /**
   * Xóa khỏi favorites (idempotent)
   * - Nếu chưa favorite -> vẫn coi là success (true)
   */
  static async removeFavorite(userId: number, songId: number): Promise<boolean> {
    this._validateIds(userId, songId);

    const existed = await FavoriteRepository.isFavorite(userId, songId);
    if (!existed) return true;

    const ok = await FavoriteRepository.remove(userId, songId);
    if (!ok) {
      throw new Error("Failed to remove from favorites");
    }
    return true;
  }

  /**
   * Lấy danh sách bài hát đã yêu thích của user
   */
  static async getFavorites(userId: number): Promise<Song[]> {
    if (!Number.isInteger(userId) || userId <= 0) {
      throw new Error("Invalid user ID");
    }
    return await FavoriteRepository.findByUserId(userId);
  }

  /**
   * Check 1 bài hát có đang favorite không
   */
  static async isFavorite(userId: number, songId: number): Promise<boolean> {
    this._validateIds(userId, songId);
    return await FavoriteRepository.isFavorite(userId, songId);
  }

  private static _validateIds(userId: number, songId: number) {
    if (!Number.isInteger(userId) || userId <= 0) {
      throw new Error("Invalid user ID");
    }
    if (!Number.isInteger(songId) || songId <= 0) {
      throw new Error("Invalid song ID");
    }
  }
}
