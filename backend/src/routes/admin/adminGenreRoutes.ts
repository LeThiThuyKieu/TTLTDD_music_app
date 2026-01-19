import { Router } from "express";
import { AdminGenreController } from "../../controllers/admin/adminGenreController";
import { authenticate } from "../../middleware/auth";
import { requireAdmin } from "../../middleware/admin";

const router = Router();

// Lấy danh sách genre ( GET /api/admin/genres )
router.get("/", authenticate, requireAdmin, AdminGenreController.getAllGenres);

export default router;