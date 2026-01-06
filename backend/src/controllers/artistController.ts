import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { ArtistService } from "../services/artistService";

export class ArtistController {
  static async getAll(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const limit = parseInt(req.query.limit as string) || 20;
      const artists = await ArtistService.getAllArtists(limit);

      res.json({
        success: true,
        data: artists,
      });
    } catch (error: any) {
      console.error("Get artists error:", error);
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  static async getById(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
      const artistId = parseInt(req.params.id);
      const artist = await ArtistService.getArtistById(artistId);

      if (!artist) {
        res.status(404).json({ error: "Artist not found" });
        return;
      }

      res.json({
        success: true,
        data: artist,
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
