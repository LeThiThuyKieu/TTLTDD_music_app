import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { PlaylistService } from "../services/playlistService";

export class PlaylistController {
  /** helper: lấy userId từ token (req.user set ở middleware) */
  private static requireUserId(req: AuthenticatedRequest, res: Response): number | null {
    const uid = req.user?.user_id;

    if (uid === undefined || uid === null) {
      res.status(401).json({ success: false, error: "Unauthorized" });
      return null;
    }

    const userId = Number(uid);
    if (!Number.isFinite(userId) || userId <= 0) {
      res.status(401).json({
        success: false,
        error: "Unauthorized: Invalid user_id",
        debug: { user: req.user },
      });
      return null;
    }

    return userId;
  }

  private static parseId(value: any): number | null {
    const n = Number(value);
    if (!Number.isFinite(n) || n <= 0) return null;
    return Math.floor(n);
  }

  // POST /playlists
  static async create(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const userId = PlaylistController.requireUserId(req, res);
      if (!userId) return;

      const name = (req.body?.name ?? "").toString().trim();
      const cover_url = req.body?.cover_url;
      const is_public = req.body?.is_public;

      if (!name) {
        res.status(400).json({ success: false, error: "Playlist name is required" });
        return;
      }

      const playlist = await PlaylistService.createPlaylist(userId, name, cover_url, is_public);

      res.status(201).json({ success: true, data: playlist });
    } catch (error: any) {
      console.error("Create playlist error:", error);
      res.status(500).json({
        success: false,
        error: "Internal server error",
        message: error?.message,
      });
    }
  }

  // GET /playlists/my
  static async getMyPlaylists(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const userId = PlaylistController.requireUserId(req, res);
      if (!userId) return;

      console.log("[GET /playlists/my] req.user =", req.user);

      const playlists = await PlaylistService.getMyPlaylists(userId);
      res.json({ success: true, data: playlists });
    } catch (error: any) {
      console.error("Get my playlists error:", error);
      res.status(500).json({
        success: false,
        error: "Internal server error",
        message: error?.message,
      });
    }
  }

  // GET /playlists/:id
  static async getById(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const playlistId = PlaylistController.parseId(req.params.id);
      if (!playlistId) {
        res.status(400).json({ success: false, error: "Invalid playlist ID" });
        return;
      }

      const playlist = await PlaylistService.getPlaylistById(playlistId);
      if (!playlist) {
        res.status(404).json({ success: false, error: "Playlist not found" });
        return;
      }

      const userId = req.user?.user_id ? Number(req.user.user_id) : undefined;

      const hasAccess = await PlaylistService.checkPlaylistAccess(playlist, userId);
      if (!hasAccess) {
        res.status(403).json({ success: false, error: "Forbidden" });
        return;
      }

      const songs = await PlaylistService.getPlaylistSongs(playlistId);
      res.json({ success: true, data: { ...playlist, songs } });
    } catch (error: any) {
      console.error("Get playlist by ID error:", error);
      res.status(500).json({
        success: false,
       error: "Internal server error",
        message: error?.message,
      });
    }
  }

  // POST /playlists/:id/songs
  static async addSong(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const userId = PlaylistController.requireUserId(req, res);
      if (!userId) return;

      const playlistId = PlaylistController.parseId(req.params.id);
      const songId = PlaylistController.parseId(req.body?.song_id);

      if (!playlistId || !songId) {
        res.status(400).json({ success: false, error: "Invalid playlist ID or song ID" });
        return;
      }

      const ok = await PlaylistService.addSongToPlaylist(playlistId, songId, userId);
      if (!ok) {
        res.status(400).json({ success: false, error: "Failed to add song to playlist" });
        return;
      }

      res.json({ success: true, message: "Song added to playlist" });
    } catch (error: any) {
      console.error("Add song to playlist error:", error);
      res.status(500).json({
        success: false,
        error: "Internal server error",
        message: error?.message,
      });
    }
  }

  // DELETE /playlists/:id/songs/:songId
  static async removeSong(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const userId = PlaylistController.requireUserId(req, res);
      if (!userId) return;

      const playlistId = PlaylistController.parseId(req.params.id);
      const songId = PlaylistController.parseId(req.params.songId);

      if (!playlistId || !songId) {
        res.status(400).json({ success: false, error: "Invalid playlist ID or song ID" });
        return;
      }

      const ok = await PlaylistService.removeSongFromPlaylist(playlistId, songId, userId);
      if (!ok) {
        res.status(400).json({ success: false, error: "Failed to remove song from playlist" });
        return;
      }

      res.json({ success: true, message: "Song removed from playlist" });
    } catch (error: any) {
      console.error("Remove song from playlist error:", error);
      res.status(500).json({
        success: false,
        error: "Internal server error",
        message: error?.message,
      });
    }
  }

  // DELETE /playlists/:id
  static async delete(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const userId = PlaylistController.requireUserId(req, res);
      if (!userId) return;

      const playlistId = PlaylistController.parseId(req.params.id);
      if (!playlistId) {
        res.status(400).json({ success: false, error: "Invalid playlist ID" });
        return;
      }

      const ok = await PlaylistService.deletePlaylist(playlistId, userId);
      if (!ok) {
        res.status(400).json({ success: false, error: "Failed to delete playlist" });
        return;
      }

      res.json({ success: true, message: "Playlist deleted" });
    } catch (error: any) {
      console.error("Delete playlist error:", error);
      res.status(500).json({
        success: false,
        error: "Internal server error",
        message: error?.message,
      });
    }
  }
}
