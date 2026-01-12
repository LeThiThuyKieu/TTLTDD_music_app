import { Router } from "express";
import { AdminGenreController } from "../../controllers/admin/adminGenreController";
import { authenticate } from "../../middleware/auth";

const router = Router();

// Lấy danh sách genre ( GET /api/admin/genres )
router.get("/", authenticate, AdminGenreController.getAllGenres);

export default router;