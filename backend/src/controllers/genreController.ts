import { Request, Response } from "express";
import { GenreService } from "../services/genreService";

export class GenreController {
  static async getAll(_req: Request, res: Response): Promise<void> {
    try {
      const genres = await GenreService.getAllGenres();
      res.json({
        success: true,
        data: genres,
      });
    } catch (error) {
      console.error("Error fetching genres:", error);
      res.status(500).json({
        success: false,
        error: "Failed to fetch genres",
      });
    }
  }

  static async getById(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const genreId = Number(id);

      if (Number.isNaN(genreId)) {
        res.status(400).json({ success: false, error: "Invalid genre ID" });
        return;
      }

      const genre = await GenreService.getGenreById(genreId);

      if (!genre) {
        res.status(404).json({ success: false, error: "Genre not found" });
        return;
      }

      res.json({
        success: true,
        data: genre,
      });
    } catch (error) {
      console.error("Error fetching genre:", error);
      res.status(500).json({
        success: false,
        error: "Failed to fetch genre",
      });
    }
  }

  static async create(req: Request, res: Response): Promise<void> {
    try {
      const genre = await GenreService.createGenre(req.body.name);
      res.status(201).json({
        success: true,
        data: genre,
      });
    } catch (error) {
      console.error("Error creating genre:", error);
      res.status(500).json({
        success: false,
        error: "Failed to create genre",
      });
    }
  }

  static async update(req: Request, res: Response): Promise<void> {
    try {
      const genreId = Number(req.params.id);

      if (Number.isNaN(genreId)) {
        res.status(400).json({ success: false, error: "Invalid genre ID" });
        return;
      }

      const updated = await GenreService.updateGenre(genreId, req.body.name);

      if (!updated) {
        res.status(404).json({ success: false, error: "Genre not found" });
        return;
      }

      res.json({
        success: true,
        data: updated,
      });
    } catch (error) {
      console.error("Error updating genre:", error);
      res.status(500).json({
        success: false,
        error: "Failed to update genre",
      });
    }
  }

  static async delete(req: Request, res: Response): Promise<void> {
    try {
      const genreId = Number(req.params.id);

      if (Number.isNaN(genreId)) {
        res.status(400).json({ success: false, error: "Invalid genre ID" });
        return;
      }

      const deleted = await GenreService.deleteGenre(genreId);

      if (!deleted) {
        res.status(404).json({ success: false, error: "Genre not found" });
        return;
      }

      res.json({
        success: true,
        message: "Genre deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting genre:", error);
      res.status(500).json({
        success: false,
        error: "Failed to delete genre",
      });
    }
  }
}
