import { AuthenticatedRequest } from "../../models";
import { AdminAlbumService } from "../../services/admin/albumAlbumService";
import { Response } from "express";

export class AdminAlbumController {
    //ADMIN: Lấy danh sách album (GET /api/admin/albums)
    static async getAllAlbums(req: AuthenticatedRequest, res: Response ){
     try {
       const limit = Number(req.query.limit) || 20;
       const offset = Number(req.query.offset) || 0;
       const albums = await AdminAlbumService.getAllAlbums(limit, offset);
    
       res.status(200).json({
        success: true,
        limit,
        offset,
        data: albums
       });
     } catch (error) {
       console.error("Lỗi khi lấy danh sách album:", error);
       res.status(500).json({
         message: "Lỗi khi lấy danh sách album"
       });
     }
    }
    //ADMIN: Xoá album theo ID (DELETE /api/admin/albums/:id)
    static async deleteAlbumById(req: AuthenticatedRequest, res: Response) {
      try {
        const album_id = Number(req.params.id);
        if (isNaN(album_id)) {
          return res.status(400).json({
            success: false,
            message: "Invalid album ID"
          });
        }
        const deleted = await AdminAlbumService.deleteAlbumById(album_id);
        if (!deleted) {
          return res.status(404).json({
            success: false,
            message: "Album not found"
          });
        }
        return res.status(200).json({
          success: true,
          message: "Album deleted successfully",
          album_id: album_id
        });
      }
      catch (error) {
        console.error("Admin delete album error:", error); 
        return res.status(500).json({
          success: false,
          message: "Failed to delete album"
        });
      }
    }
}