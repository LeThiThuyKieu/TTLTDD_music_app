import { Router } from "express";
import { AdminArtistController } from "../../controllers/admin/adminArtistController";
import { authenticate } from "../../middleware/auth";

const router = Router();

// Lấy danh sách nghệ sĩ ( GET /api/admin/artists )
router.get("/", authenticate, AdminArtistController.getAllArtists);

export default router;