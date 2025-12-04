import { Response } from "express";
import { AuthenticatedRequest } from "../types";
import { FavoriteService } from "../services/favoriteService";

export class FavoriteController {
  // Thêm vào favorites
  static async add(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const songId = parseInt(req.params.songId);
      if (isNaN(songId)) {
        res.status(400).json({ error: "Invalid song ID" });
        return;
      }

      const success = await FavoriteService.addFavorite(req.user.uid, songId);
      if (!success) {
        res.status(400).json({ error: "Failed to add to favorites" });
        return;
      }

      res.json({
        success: true,
        message: "Added to favorites",
      });
    } catch (error: any) {
      console.error("Add favorite error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Xóa khỏi favorites
  static async remove(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const songId = parseInt(req.params.songId);
      if (isNaN(songId)) {
        res.status(400).json({ error: "Invalid song ID" });
        return;
      }

      const success = await FavoriteService.removeFavorite(
        req.user.uid,
        songId
      );
      if (!success) {
        res.status(400).json({ error: "Failed to remove from favorites" });
        return;
      }

      res.json({
        success: true,
        message: "Removed from favorites",
      });
    } catch (error: any) {
      console.error("Remove favorite error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy danh sách favorites
  static async getAll(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const favorites = await FavoriteService.getFavorites(req.user.uid);

      res.json({
        success: true,
        data: favorites,
      });
    } catch (error: any) {
      console.error("Get favorites error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Kiểm tra có trong favorites không
  static async check(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const songId = parseInt(req.params.songId);
      if (isNaN(songId)) {
        res.status(400).json({ error: "Invalid song ID" });
        return;
      }

      const isFavorite = await FavoriteService.isFavorite(req.user.uid, songId);

      res.json({
        success: true,
        data: { isFavorite },
      });
    } catch (error: any) {
      console.error("Check favorite error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}
