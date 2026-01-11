import { AuthenticatedRequest } from "../../models";
import { Response } from "express";
import { AdminSongService } from "../../services/admin/adminSongService";

export class AdminSongController {
  //ADMIN: Lấy danh sách bài hát (GET /api/admin/songs)
    static async getAllSongs(req: AuthenticatedRequest, res: Response ){
     try {
       const limit = Number(req.query.limit) || 20;
       const offset = Number(req.query.offset) || 0;

       const songs = await AdminSongService.getAllSongs(limit, offset);

   res.status(200).json({
        success: true,
        limit,
        offset,
        data: songs
      });
    } catch (error) {
      console.error("Admin get songs error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to fetch admin songs"
      });
    }
  }
  //ADMIN: Lấy XOÁ bài hát theo ID (DELETE /api/admin/songs/:id)
  static async deleteSongById(req: AuthenticatedRequest, res: Response) {
    try {
      const song_id = Number(req.params.id);
      if (isNaN(song_id)) {
        return res.status(400).json({
          success: false,
          message: "Invalid song ID"
        });
      }
      const deleted = await AdminSongService.deleteSongById(song_id);
      if (!deleted) {
        return res.status(404).json({
          success: false,
          message: "Song not found"
        });
      }
      return res.status(200).json({
        success: true,
        message: "Song deleted successfully",
        song_id: song_id
      });
    } catch (error) {
      console.error("Admin delete song error:", error); 
      return res.status(500).json({
        success: false,
        message: "Failed to delete song"
      });
    }
  }

}
