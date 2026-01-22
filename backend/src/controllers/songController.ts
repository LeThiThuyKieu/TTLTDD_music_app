import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { SongService } from "../services/songService";

export class SongController {
  // Lấy danh sách bài hát
  static async getAll(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const limit = parseInt(req.query.limit as string) || 50;
      const offset = parseInt(req.query.offset as string) || 0;

      const songs = await SongService.getAllSongs(limit, offset);

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

      const song = await SongService.getSongById(songId);
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
      const songs = await SongService.searchSongs(query, limit);

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

      const songs = await SongService.getSongsByGenre(genreId, limit, offset);

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
      const song = await SongService.createSong(songData);

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
  // Lấy bài hát theo artist
  static async getByArtist(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      const artistId = parseInt(req.params.artistId);
      if (isNaN(artistId)) {
        res.status(400).json({ error: "Invalid artist ID" });
        return;
      }
      const limit = parseInt(req.query.limit as string) || 50;
      const offset = parseInt(req.query.offset as string) || 0;
      const songs = await SongService.getSongsByArtist(artistId, limit, offset);
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
      console.error("Get songs by artist error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy chi tiết bài hát
  static async getDetail(
  req: AuthenticatedRequest,
  res: Response
): Promise<void> {
  try {
    const songId = parseInt(req.params.id);
    if (isNaN(songId)) {
      res.status(400).json({ error: "Invalid song ID" });
      return;
    }

    const song = await SongService.getSongDetail(songId);

    if (!song) {
      res.status(404).json({
        success: false,
        error: "Song not found",
      });
      return;
    }

    res.json({
      success: true,
      data: song,
    });
  } catch (error: any) {
    console.error("Get song detail error:", error);
    res.status(500).json({
      success: false,
      error: error.message || "Internal server error",
    });
  }
}
 // Gợi ý bài hát ưu tiên: cùng playlist -> cùng nghệ sĩ -> cùng thể loại -> phổ biến/ngẫu nhiên
  static async getRecommendations(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      const songId = parseInt(req.params.id);
      if (isNaN(songId)) {
        res.status(400).json({ error: "Invalid song ID" });
        return;
      }

      const limitRaw = parseInt(req.query.limit as string);
      const limit = Number.isFinite(limitRaw)
        ? Math.min(Math.max(limitRaw, 1), 50)
        : 20;

      // userId có thể null nếu chưa đăng nhập (optionalAuth)
      const userId = req.user?.user_id ?? null;

      const songs = await SongService.getRecommendedSongs(
        songId,
        userId,
        limit
      );

      res.json({
        success: true,
        data: songs,
        pagination: {
          limit,
          count: songs.length,
        },
      });
    } catch (error: any) {
      if (error?.message === "Song not found") {
        res.status(404).json({ success: false, error: "Song not found" });
        return;
      }
      console.error("Get recommended songs error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}
