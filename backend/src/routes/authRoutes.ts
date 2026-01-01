import { Router } from "express";
import { AuthController } from "../controllers/authController";
import { authenticate } from "../middleware/auth";
import { validate, validateRegister, validateLogin } from "../utils/validation";

const router = Router();

// Đăng ký user mới
router.post("/register", validate(validateRegister), AuthController.register);

// Đăng nhập
router.post("/login", validate(validateLogin), AuthController.login);

// Lấy thông tin user hiện tại
router.get("/me", authenticate, AuthController.getCurrentUser);

export default router;
