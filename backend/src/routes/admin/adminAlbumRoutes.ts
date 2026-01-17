import { Router } from "express";
import { authenticate } from "../../middleware/auth";
import { AdminAlbumController } from "../../controllers/admin/adminAlbumController";
import { uploadFiles } from "../../middleware/uploadCloud";
import { requireAdmin } from "../../middleware/admin";

const router = Router();

//Lấy danh sách album ( GET /api/admin/albums )
router.get("/", authenticate, requireAdmin, AdminAlbumController.getAllAlbums);

// Xoá album theo ID ( DELETE /api/admin/albums/:id )
router.delete("/:id", authenticate, requireAdmin, AdminAlbumController.deleteAlbumById);

// LẤY CHI TIẾT ALBUM THEO ID ( GET /api/admin/albums/:id )
router.get("/:id", authenticate, requireAdmin, AdminAlbumController.getAlbumById);

// TẠO MỚI ALBUM ( POST /api/admin/albums )
router.post("/", authenticate, requireAdmin, uploadFiles, AdminAlbumController.createAlbum);

// CẬP NHẬT ALBUM THEO ID ( PUT /api/admin/albums/:id )
router.put("/:id", authenticate, requireAdmin, uploadFiles, AdminAlbumController.updateAlbum);
export default router;