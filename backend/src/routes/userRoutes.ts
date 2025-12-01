import { Router } from "express";
import { UserController } from "../controllers/userController";
import { authenticateFirebase } from "../middleware/auth";

const router = Router();

// Tất cả routes đều cần authentication
router.use(authenticateFirebase);

// Cập nhật profile
router.put("/profile", UserController.updateProfile);

// Lấy thông tin user theo ID
router.get("/:id", UserController.getUserById);

export default router;




