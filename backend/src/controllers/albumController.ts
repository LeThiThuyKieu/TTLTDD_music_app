import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { AlbumService } from "../services/albumService";

export class AlbumController {
  static async getAll(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const limit = parseInt(req.query.limit as string) || 50;
      const offset = parseInt(req.query.offset as string) || 0;

      const albums = await AlbumService.getAllAlbums(limit, offset);

      res.json({
        success: true,
        data: albums,
        pagination: {
          limit,
          offset,
          count: albums.length,
        },
      });
    } catch (error: any) {
      console.error("Get all albums error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  static async getById(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const albumId = parseInt(req.params.id);
      if (isNaN(albumId)) {
        res.status(400).json({ error: "Invalid album ID" });
        return;
      }

      const album = await AlbumService.getAlbumById(albumId);
      if (!album) {
        res.status(404).json({ error: "Album not found" });
        return;
      }

      res.json({ success: true, data: album });
    } catch (error: any) {
      console.error("Get album by ID error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  static async getSongs(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const albumId = parseInt(req.params.id);
      if (isNaN(albumId)) {
        res.status(400).json({ error: "Invalid album ID" });
        return;
      }

      const songs = await AlbumService.getSongs(albumId);
      res.json({ success: true, data: songs });
    } catch (error: any) {
      console.error("Get album songs error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}