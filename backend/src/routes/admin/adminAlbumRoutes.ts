import { Router } from "express";
import { authenticate } from "../../middleware/auth";
import { AdminAlbumController } from "../../controllers/admin/adminAlbumController";
import { uploadFiles } from "../../middleware/uploadCloud";

const router = Router();

//Lấy danh sách album ( GET /api/admin/albums )
router.get("/", authenticate, AdminAlbumController.getAllAlbums);

// Xoá album theo ID ( DELETE /api/admin/albums/:id )
router.delete("/:id", authenticate, AdminAlbumController.deleteAlbumById);

// LẤY CHI TIẾT ALBUM THEO ID ( GET /api/admin/albums/:id )
router.get("/:id", authenticate, AdminAlbumController.getAlbumById);

// TẠO MỚI ALBUM ( POST /api/admin/albums )
router.post("/", authenticate, uploadFiles, AdminAlbumController.createAlbum);

// CẬP NHẬT ALBUM THEO ID ( PUT /api/admin/albums/:id )
router.put("/:id", authenticate, uploadFiles, AdminAlbumController.updateAlbum);
export default router;