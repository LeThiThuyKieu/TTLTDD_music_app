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
    }
