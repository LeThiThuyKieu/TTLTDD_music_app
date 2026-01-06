import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { SongService } from "../services/songService";

export class SongController {
  // GET /api/songs?limit=50&offset=0
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
        error: error?.message || "Internal server error",
      });
    }
  }

  // GET /api/songs/:id
  static async getById(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const songId = parseInt(req.params.id);
      if (isNaN(songId)) {
        res.status(400).json({ success: false, error: "Invalid song ID" });
        return;
      }

      const song = await SongService.getSongById(songId);
      if (!song) {
        res.status(404).json({ success: false, error: "Song not found" });
        return;
      }

      res.json({ success: true, data: song });
    } catch (error: any) {
      console.error("Get song by id error:", error);
      res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }

  // GET /api/songs/search?q=abc&limit=50
  static async search(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const q = (req.query.q as string | undefined)?.trim();
      if (!q) {
        res.status(400).json({ success: false, error: "Missing query param: q" });
        return;
      }

      const limit = parseInt(req.query.limit as string) || 50;
      const songs = await SongService.searchSongs(q, limit);

      res.json({
        success: true,
        data: songs,
        pagination: {
          limit,
          offset: 0,
          count: songs.length,
        },
      });
    } catch (error: any) {
      console.error("Search songs error:", error);
      res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }

  // GET /api/songs/genre/:genreId?limit=50&offset=0
  static async getByGenre(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const genreId = parseInt(req.params.genreId);
      if (isNaN(genreId)) {
        res.status(400).json({ success: false, error: "Invalid genre ID" });
        return;
      }

      const limit = parseInt(req.query.limit as string) || 50;
      const offset = parseInt(req.query.offset as string) || 0;

      const songs = await SongService.getSongsByGenre(genreId, limit, offset);

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
      console.error("Get songs by genre error:", error);
      res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }

  // POST /api/songs  (admin only sau)
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
        error: error?.message || "Internal server error",
      });
    }
  }

  // (OPTIONAL) GET /api/songs/artist/:artistId?limit=50&offset=0
  // Chỉ dùng nếu SongService có getSongsByArtist()
  static async getByArtist(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const artistId = parseInt(req.params.artistId);
      if (isNaN(artistId)) {
        res.status(400).json({ success: false, error: "Invalid artist ID" });
        return;
      }

      const limit = parseInt(req.query.limit as string) || 50;
      const offset = parseInt(req.query.offset as string) || 0;

      // ✅ Nếu bạn đã có hàm này thì mở comment:
      // const songs = await SongService.getSongsByArtist(artistId, limit, offset);

      // Tạm thời để không crash compile khi chưa có service:
      const songs: any[] = [];

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
        error: error?.message || "Internal server error",
      });
    }
  }
}
