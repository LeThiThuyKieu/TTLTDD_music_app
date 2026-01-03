import { Router } from "express";
import { FavoriteController } from "../controllers/favoriteController";
import { authenticate } from "../middleware/auth";

const router = Router();

// Tất cả routes đều cần authentication
router.use(authenticate);

// Lấy danh sách favorites
router.get("/", FavoriteController.getAll);

// Kiểm tra có trong favorites không
router.get("/:songId/check", FavoriteController.check);

// Thêm vào favorites
router.post("/:songId", FavoriteController.add);

// Xóa khỏi favorites
router.delete("/:songId", FavoriteController.remove);

export default router;
