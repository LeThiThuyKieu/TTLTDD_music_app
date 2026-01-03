import { FavoriteRepository } from "../repositories/FavoriteRepository";
import { Song } from "../models";

export class FavoriteService {
  // Thêm vào favorites
  static async addFavorite(userId: number, songId: number): Promise<boolean> {
    return await FavoriteRepository.add(userId, songId);
  }

  // Xóa khỏi favorites
  static async removeFavorite(
    userId: number,
    songId: number
  ): Promise<boolean> {
    return await FavoriteRepository.remove(userId, songId);
  }

  // Lấy danh sách favorites
  static async getFavorites(userId: number): Promise<Song[]> {
    return await FavoriteRepository.findByUserId(userId);
  }

  // Kiểm tra có trong favorites không
  static async isFavorite(userId: number, songId: number): Promise<boolean> {
    return await FavoriteRepository.isFavorite(userId, songId);
  }
}
