import { uploadToCloudinary } from "../../config/cloudinary";
import { AuthenticatedRequest } from "../../models";
import { AdminArtistService } from "../../services/admin/adminArtistService";
import { Response } from "express";

export class AdminArtistController {
//ADMIN: lấy danh sách nghệ sĩ ( GET /api/admin/artists )
    static async getAllArtists(req: AuthenticatedRequest, res: Response) {
       try {
       const limit = Number(req.query.limit) || 20;
       const offset = Number(req.query.offset) || 0;
         const artists = await AdminArtistService.getAllArtists(limit, offset);
            res.status(200).json({
        success: true,
        limit,
        offset,
        data: artists
        });
        } catch (error) {
        console.error("Admin get artists error:", error);
        res.status(500).json({
        success: false,
        message: "Failed to fetch admin artists"
        });
        }
        }

        // ADMIN: Lấy chi tiết nghệ sĩ theo ID ( GET /api/admin/artists/:id )
       static async getArtistById(req: AuthenticatedRequest, res: Response) {
  try {
    const artist_id = Number(req.params.id);

    if (isNaN(artist_id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid artist ID",
      });
    }

    const artist = await AdminArtistService.getArtistById(artist_id);

    if (!artist) {
      return res.status(404).json({
        success: false,
        message: "Artist not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: artist,
    });
  } catch (error) {
    console.error("Get artist detail error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch artist detail",
    });
  }
}

        //ADMIN: Xoá nghệ sĩ theo ID ( DELETE /api/admin/artists/:id )
        static async deleteArtistById(req: AuthenticatedRequest, res: Response) {
          try {
            const artist_id = Number(req.params.id);    
            if (isNaN(artist_id)) {
                return res.status(400).json({
                    success: false,
                    message: "Invalid artist ID"
                });
            }
            const deleted = await AdminArtistService.deleteArtistById(artist_id);
            if (!deleted) {
                return res.status(404).json({
                    success: false,
                    message: "Artist not found",
                    artist_id: artist_id
                });
            }
            return res.status(200).json({
                success: true,
                message: "Artist deleted successfully", 
                artist_id: artist_id
            });
          }
            catch (error) {
                console.error("Admin delete artist error:", error);
                return res.status(500).json({
                    success: false,
                    message: "Failed to delete artist"
                });
            }
        }

        //ADMIN: Thêm nghệ sĩ ( POST /api/admin/artists )
       static async createArtist(req: AuthenticatedRequest, res: Response) {
  try {
    const { name, description } = req.body;

    if (!name) {
      return res.status(400).json({
        success: false,
        message: "Name is required",
      });
    }

    const files = req.files as {
      [fieldname: string]: Express.Multer.File[];
    };

    const avatarFile = files?.avatar?.[0];
    if (!avatarFile) {
      return res.status(400).json({
        success: false,
        message: "Avatar is required",
      });
    }

    const upload = await uploadToCloudinary(
      avatarFile,
      "artists/avatar",
      `artist_${Date.now()}`
    );

    const artist = await AdminArtistService.createArtist({
      name,
      description,
      avatar_url: upload.url,
      avatar_public_id: upload.public_id,
    });

    return res.status(201).json({
      success: true,
      data: artist,
    });
  } catch (error) {
    console.error("Create artist error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to create artist",
    });
  }
}

  //   ADMIN: Cập nhật nghệ sĩ theo ID ( PUT /api/admin/artists/:id )
   static async updateArtist(req: AuthenticatedRequest, res: Response) {
  try {
    const artist_id = Number(req.params.id);
    const { name, description, is_active } = req.body;

    if (isNaN(artist_id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid artist ID",
      });
    }

    if (!name) {
      return res.status(400).json({
        success: false,
        message: "Name is required",
      });
    }

    const files = req.files as {
      [fieldname: string]: Express.Multer.File[];
    };

    const avatarFile = files?.avatar?.[0];
    

    let upload;
    if (avatarFile) {
      
      upload = await uploadToCloudinary(
        avatarFile,
        "artists/avatar",
        `artist_${artist_id}`
      );
    }

    const artist = await AdminArtistService.updateArtist(artist_id, {
      name,
      description,
      is_active: Number(is_active) === 1,
      avatar_url: upload?.url,
      avatar_public_id: upload?.public_id,
    });

    return res.status(200).json({
      success: true,
      data: artist,
    });
  } catch (error) {
    console.error("Update artist error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to update artist",
    });
  }
}

 }
