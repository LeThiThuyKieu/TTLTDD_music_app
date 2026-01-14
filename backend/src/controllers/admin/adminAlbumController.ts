import { uploadToCloudinary } from "../../config/cloudinary";
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

    // LẤY CHI TIẾT ALBUM THEO ID (GET /api/admin/albums/:id)
    static async getAlbumById(req: AuthenticatedRequest, res: Response)
    : Promise<void> {
    try {
      const album_id = Number(req.params.id);
      if (isNaN(album_id)) {
         res.status(400).json({ 
      success: false,
       message: "Invalid album ID"
       });
          return;
      }
      const album = await AdminAlbumService.getAlbumById(album_id);
      
      if (!album){
         res.status(404).json({ 
          success: false, 
          message: "Album not found" 
        });
          return;
      }
      res.status(200).json({ 
        success: true,
         data: album 
        });
    } catch (error) {
      console.error("Lỗi khi lấy chi tiết album:", error);
      res.status(500).json({ 
        success: false, 
        message: "Lỗi khi lấy chi tiết album" 
      });
    }
  }

  // TẠO MỚI ALBUM (POST /api/admin/albums)
  static async createAlbum(req: AuthenticatedRequest, res: Response)
  : Promise<void> {
    try {
      const { title, artist_id, is_active, song_ids } = req.body;

      if (!title) {
         res.status(400).json({
         success: false, 
         message: "Title is required"
         });
          return;
      }

      // Xử lý file cover
      const files = req.files as { [key: string]: Express.Multer.File[] };
      const coverFile = files?.cover?.[0];

      let cover_url: string | undefined;
      let album_public_id: string | undefined;

      if (coverFile) {
        const publicId = `albums/cover_${Date.now()}`;
        const uploaded = await uploadToCloudinary(coverFile, "albums/cover", publicId);
        cover_url = uploaded.url;
        album_public_id = uploaded.public_id;
      }
      const parsedSongIds =
      Array.isArray(song_ids)
        ? song_ids.map(Number)
        : typeof song_ids === "string"
        ? song_ids.split(",").map(Number)
        : [];

      const album = await AdminAlbumService.createAlbum({
        title,
        artist_id: artist_id ? Number(artist_id) : undefined,
        is_active: is_active !== undefined ? Number(is_active) : 1,
        cover_url,
        album_public_id,
        song_ids: parsedSongIds,
      });

      res.status(201).json({ success: true, data: album });

    } catch (error) {
      console.error("Lỗi khi tạo album:", error);
      res.status(500).json({ success: false, message: "Failed to create album" });
    }
  }
  // CẬP NHẬT ALBUM THEO ID (PUT /api/admin/albums/:id)
  static async updateAlbum(req: AuthenticatedRequest, res: Response)
  : Promise<void> {
    try {
      const album_id = Number(req.params.id);
      if (isNaN(album_id)){ 
         res.status(400).json({ 
          success: false, 
          message: "Invalid album ID" 
        });
          return;
      }

      const { title, artist_id, is_active, song_ids } = req.body;

      // parse song_ids (chập nhận csv, array hoặc undefined)
       let parsedSongIds: number[] | undefined;
        if (song_ids !== undefined) {
      parsedSongIds = Array.isArray(song_ids)
        ? song_ids.map(Number)
        : typeof song_ids === "string"
        ? song_ids.split(",").map(Number)
        : [];

      parsedSongIds = parsedSongIds.filter(id => !isNaN(id));
    }
    // Xử lý file cover
      const files = req.files as { [key: string]: Express.Multer.File[] };
      const coverFile = files?.cover?.[0];

      let cover_url: string | undefined;
      let album_public_id: string | undefined;

      if (coverFile) {
        const publicId = `albums/cover_${album_id}`;
        const uploaded = await uploadToCloudinary(coverFile, "albums/cover", publicId);
        cover_url = uploaded.url;
        album_public_id = uploaded.public_id;
      }
        // Gọi service để cập nhật album
      const album = await AdminAlbumService.updateAlbum(album_id, {
        title,
        artist_id: artist_id ? Number(artist_id) : undefined,
        is_active: is_active !== undefined ? Number(is_active) : undefined,
        cover_url,
        album_public_id,
        song_ids: parsedSongIds,
      });

      res.status(200).json({ success: true, data: album });
    } catch (error) {
      console.error("Lỗi khi cập nhật album:", error);
      res.status(500).json({ success: false, message: "Failed to update album" });
    }
  }

}