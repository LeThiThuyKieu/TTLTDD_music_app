import { AuthenticatedRequest } from "../../models";
import { AdminGenreService } from "../../services/admin/adminGenreService";
import { Response } from "express";

export class AdminGenreController {
//ADMIN: lấy danh sách genre ( GET /api/admin/genres )
    static async getAllGenres(req: AuthenticatedRequest, res: Response) {
       try {
       const limit = Number(req.query.limit) || 20; 
        const offset = Number(req.query.offset) || 0;
        const genres = await AdminGenreService.getAllGenres(limit, offset);
            res.status(200).json({
        success: true,
        limit,
        offset,
        data: genres
        });
        }
        catch (error) {
        console.error("Admin get genres error:", error);
        res.status(500).json({
        success: false,
        message: "Failed to fetch admin genres"
        });
        }
        }
}