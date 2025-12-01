import { Router } from "express";
import { AuthController } from "../controllers/authController";
import { authenticateFirebase } from "../middleware/auth";
import { validate, validateUser } from "../utils/validation";

const router = Router();

// Sync user sau khi đăng nhập Firebase
router.post(
  "/sync",
  authenticateFirebase,
  validate(validateUser),
  AuthController.syncUser
);

// Lấy thông tin user hiện tại
router.get("/me", authenticateFirebase, AuthController.getCurrentUser);

export default router;




