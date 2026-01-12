import { Router } from "express";
import { UserController } from "../controllers/userController";
import { authenticate } from "../middleware/auth";
import { uploadAvatar } from "../middleware/upload";

const router = Router();

// Tất cả routes đều cần authentication
router.use(authenticate);

// Lấy thông tin user theo ID
router.get("/:id", UserController.getUserById);

// Change password (trong profile)
router.post("/change-password", UserController.changePassword);

// Cập nhật profile
router.put("/name-profile", UserController.updateNameProfile);

// Upload avatar
router.post(
  "/upload-avatar",
  // uploadAvatar.single("avatar"),
  uploadAvatar,
  UserController.uploadAvatar
);

export default router;
