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
}
