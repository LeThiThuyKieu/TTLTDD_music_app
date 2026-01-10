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
    }
