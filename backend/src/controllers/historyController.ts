import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { HistoryService } from "../services/historyService";

export class HistoryController {
  // Thêm vào history
  static async add(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const { song_id, listened_duration } = req.body;
      const songId = parseInt(song_id);

      if (isNaN(songId)) {
        res.status(400).json({ error: "Invalid song ID" });
        return;
      }

      const history = await HistoryService.addHistory(
        req.user.uid,
        songId,
        listened_duration || 0
      );

      res.status(201).json({
        success: true,
        data: history,
      });
    } catch (error: any) {
      console.error("Add history error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy lịch sử nghe
  static async getAll(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const limit = parseInt(req.query.limit as string) || 50;
      const history = await HistoryService.getHistory(req.user.uid, limit);

      res.json({
        success: true,
        data: history,
      });
    } catch (error: any) {
      console.error("Get history error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Xóa lịch sử
  static async clear(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const success = await HistoryService.clearHistory(req.user.uid);
      if (!success) {
        res.status(400).json({ error: "Failed to clear history" });
        return;
      }

      res.json({
        success: true,
        message: "History cleared",
      });
    } catch (error: any) {
      console.error("Clear history error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}
