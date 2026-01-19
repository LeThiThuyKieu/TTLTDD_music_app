import { Router } from "express";
import { AdminSongController } from "../../controllers/admin/adminSongController";
import { authenticate } from "../../middleware/auth";
import { uploadFiles } from "../../middleware/uploadCloud";
import { requireAdmin } from "../../middleware/admin";
// import { requireAdmin } from "../../middleware/requireAdmin";

const router = Router();

// lấy danh sách bài hát select
router.get('/select', authenticate, requireAdmin, AdminSongController.getSongsForSelect);
// Lấy danh sách bài hát ( GET /api/admin/songs )
router.get("/", authenticate, requireAdmin, AdminSongController.getAllSongs);

// Lấy bài hát theo id ( GET /api/admin/songs/:id )
router.get("/:id", authenticate, requireAdmin,  AdminSongController.getSongById);

// Thêm bài hát ( POST /api/admin/songs )
router.post("/", authenticate, requireAdmin, uploadFiles, AdminSongController.createSong);

// // Cập nhập bài hát ( PUT /api/admin/songs )
router.put("/:id", authenticate, requireAdmin, uploadFiles, AdminSongController.updateSong);

// // Xoá bài hát ( DELETE /api/admin/songs )
router.delete("/:id", authenticate, requireAdmin, AdminSongController.deleteSongById);

export default router;



