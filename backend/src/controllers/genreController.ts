import { Request, Response } from "express";
import { GenreService } from "../services/genreService";

export class GenreController {
  // GET /api/genres
  static async getAll(req: Request, res: Response) {
    try {
      const genres = await GenreService.getAllGenres();
      return res.json({ success: true, data: genres });
    } catch (error: any) {
      console.error("Get all genres error:", error);
      return res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }

  // GET /api/genres/:id
  static async getById(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (!Number.isFinite(id) || id <= 0) {
        return res.status(400).json({ success: false, error: "Invalid genre id" });
      }

      const genre = await GenreService.getGenreById(id);
      if (!genre) {
        return res.status(404).json({ success: false, error: "Genre not found" });
      }

      return res.json({ success: true, data: genre });
    } catch (error: any) {
      console.error("Get genre by id error:", error);
      return res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }

  // POST /api/genres (protected)
  static async create(req: Request, res: Response) {
    try {
      const name = (req.body?.name ?? "").toString().trim();
      if (!name) return res.status(400).json({ success: false, error: "Name is required" });

      const created = await GenreService.createGenre(name);
      return res.status(201).json({ success: true, data: created });
    } catch (error: any) {
      console.error("Create genre error:", error);
      return res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }

  // PUT /api/genres/:id (protected)
  static async update(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (!Number.isFinite(id) || id <= 0) {
        return res.status(400).json({ success: false, error: "Invalid genre id" });
      }

      const name = (req.body?.name ?? "").toString().trim();
      if (!name) return res.status(400).json({ success: false, error: "Name is required" });

      const updated = await GenreService.updateGenre(id, name);
      if (!updated) return res.status(404).json({ success: false, error: "Genre not found" });

      return res.json({ success: true, data: updated });
    } catch (error: any) {
      console.error("Update genre error:", error);
      return res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }

  // DELETE /api/genres/:id (protected)
  static async delete(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (!Number.isFinite(id) || id <= 0) {
        return res.status(400).json({ success: false, error: "Invalid genre id" });
      }

      const ok = await GenreService.deleteGenre(id);
      if (!ok) return res.status(404).json({ success: false, error: "Genre not found" });

      return res.json({ success: true, message: "Deleted" });
    } catch (error: any) {
      console.error("Delete genre error:", error);
      return res.status(500).json({
        success: false,
        error: error?.message || "Internal server error",
      });
    }
  }
}
