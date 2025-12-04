import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { PlaylistService } from "../services/playlistService";

export class PlaylistController {
  // Tạo playlist mới
  static async create(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const { name, cover_url, is_public } = req.body;
      const playlist = await PlaylistService.createPlaylist(
        req.user.uid,
        name,
        cover_url,
        is_public
      );

      res.status(201).json({
        success: true,
        data: playlist,
      });
    } catch (error: any) {
      console.error("Create playlist error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy playlists của user
  static async getMyPlaylists(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const playlists = await PlaylistService.getMyPlaylists(req.user.uid);

      res.json({
        success: true,
        data: playlists,
      });
    } catch (error: any) {
      console.error("Get my playlists error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy playlist theo ID
  static async getById(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      const playlistId = parseInt(req.params.id);
      if (isNaN(playlistId)) {
        res.status(400).json({ error: "Invalid playlist ID" });
        return;
      }

      const playlist = await PlaylistService.getPlaylistById(playlistId);
      if (!playlist) {
        res.status(404).json({ error: "Playlist not found" });
        return;
      }

      // Kiểm tra quyền truy cập
      const hasAccess = await PlaylistService.checkPlaylistAccess(
        playlist,
        req.user?.uid
      );
      if (!hasAccess) {
        res.status(403).json({ error: "Forbidden" });
        return;
      }

      const songs = await PlaylistService.getPlaylistSongs(playlistId);

      res.json({
        success: true,
        data: {
          ...playlist,
          songs,
        },
      });
    } catch (error: any) {
      console.error("Get playlist by ID error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Thêm bài hát vào playlist
  static async addSong(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const playlistId = parseInt(req.params.id);
      const songId = parseInt(req.body.song_id);

      if (isNaN(playlistId) || isNaN(songId)) {
        res.status(400).json({ error: "Invalid playlist ID or song ID" });
        return;
      }

      const success = await PlaylistService.addSongToPlaylist(
        playlistId,
        songId,
        req.user.uid
      );
      if (!success) {
        res.status(400).json({ error: "Failed to add song to playlist" });
        return;
      }

      res.json({
        success: true,
        message: "Song added to playlist",
      });
    } catch (error: any) {
      console.error("Add song to playlist error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Xóa bài hát khỏi playlist
  static async removeSong(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const playlistId = parseInt(req.params.id);
      const songId = parseInt(req.params.songId);

      if (isNaN(playlistId) || isNaN(songId)) {
        res.status(400).json({ error: "Invalid playlist ID or song ID" });
        return;
      }

      const success = await PlaylistService.removeSongFromPlaylist(
        playlistId,
        songId,
        req.user.uid
      );
      if (!success) {
        res.status(400).json({ error: "Failed to remove song from playlist" });
        return;
      }

      res.json({
        success: true,
        message: "Song removed from playlist",
      });
    } catch (error: any) {
      console.error("Remove song from playlist error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Xóa playlist
  static async delete(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const playlistId = parseInt(req.params.id);
      if (isNaN(playlistId)) {
        res.status(400).json({ error: "Invalid playlist ID" });
        return;
      }

      const success = await PlaylistService.deletePlaylist(
        playlistId,
        req.user.uid
      );
      if (!success) {
        res.status(400).json({ error: "Failed to delete playlist" });
        return;
      }

      res.json({
        success: true,
        message: "Playlist deleted",
      });
    } catch (error: any) {
      console.error("Delete playlist error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}
