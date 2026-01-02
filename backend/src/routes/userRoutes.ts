import { Router } from "express";
import { UserController } from "../controllers/userController";
import { authenticate } from "../middleware/auth";

const router = Router();

// Tất cả routes đều cần authentication
router.use(authenticate);


// Lấy thông tin user theo ID
router.get("/:id", UserController.getUserById);

// Change password (trong profile)
router.post("/change-password", UserController.changePassword);

// Cập nhật profile
router.put("/name-profile", UserController.updateNameProfile);

export default router;
