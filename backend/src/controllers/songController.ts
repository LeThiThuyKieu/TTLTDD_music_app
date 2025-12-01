import { Response } from "express";
import { AuthenticatedRequest } from "../types";
import { SongModel } from "../models/Song";

export class SongController {
  // Lấy danh sách bài hát
  static async getAll(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const limit = parseInt(req.query.limit as string) || 50;
      const offset = parseInt(req.query.offset as string) || 0;

      const songs = await SongModel.findAll(limit, offset);

      res.json({
        success: true,
        data: songs,
        pagination: {
          limit,
          offset,
          count: songs.length,
        },
      });
    } catch (error: any) {
      console.error("Get all songs error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy bài hát theo ID
  static async getById(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      const songId = parseInt(req.params.id);
      if (isNaN(songId)) {
        res.status(400).json({ error: "Invalid song ID" });
        return;
      }

      const song = await SongModel.findByIdWithArtists(songId);
      if (!song) {
        res.status(404).json({ error: "Song not found" });
        return;
      }

      res.json({
        success: true,
        data: song,
      });
    } catch (error: any) {
      console.error("Get song by ID error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Tìm kiếm bài hát
  static async search(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const query = req.query.q as string;
      if (!query) {
        res.status(400).json({ error: "Search query is required" });
        return;
      }

      const limit = parseInt(req.query.limit as string) || 50;
      const songs = await SongModel.search(query, limit);

      res.json({
        success: true,
        data: songs,
        query,
      });
    } catch (error: any) {
      console.error("Search songs error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy bài hát theo genre
  static async getByGenre(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      const genreId = parseInt(req.params.genreId);
      if (isNaN(genreId)) {
        res.status(400).json({ error: "Invalid genre ID" });
        return;
      }

      const limit = parseInt(req.query.limit as string) || 50;
      const offset = parseInt(req.query.offset as string) || 0;

      const songs = await SongModel.findByGenre(genreId, limit, offset);

      res.json({
        success: true,
        data: songs,
      });
    } catch (error: any) {
      console.error("Get songs by genre error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Tạo bài hát mới (Admin only - có thể thêm middleware sau)
  static async create(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const songData = req.body;
      const song = await SongModel.create(songData);

      res.status(201).json({
        success: true,
        data: song,
      });
    } catch (error: any) {
      console.error("Create song error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}




