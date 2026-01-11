import { Router } from "express";
import { authenticate } from "../../middleware/auth";
import { AdminAlbumController } from "../../controllers/admin/adminAlbumController";

const router = Router();

//Lấy danh sách album ( GET /api/admin/albums )
router.get("/", authenticate, AdminAlbumController.getAllAlbums);

// Xoá album theo ID ( DELETE /api/admin/albums/:id )
router.delete("/:id", authenticate, AdminAlbumController.deleteAlbumById);
export default router;