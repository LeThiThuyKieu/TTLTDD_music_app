import { Router } from "express";
import { AuthController } from "../controllers/authController";
import { authenticate } from "../middleware/auth";
import {
  validate,
  validateRegister,
  validateLogin,
  validateForgotPassword,
  validateVerifyOTP,
  validateResetPassword,
} from "../utils/validation";

const router = Router();

// Đăng ký user mới
router.post("/register", validate(validateRegister), AuthController.register);

// Đăng nhập
router.post("/login", validate(validateLogin), AuthController.login);

// Lấy thông tin user hiện tại
router.get("/me", authenticate, AuthController.getCurrentUser);

// Quên mật khẩu - Gửi OTP
router.post(
  "/forgot-password",
  validate(validateForgotPassword),
  AuthController.forgotPassword
);

// Verify OTP
router.post(
  "/verify-otp",
  validate(validateVerifyOTP),
  AuthController.verifyOTP
);

// Reset password
router.post(
  "/reset-password",
  validate(validateResetPassword),
  AuthController.resetPassword
);

export default router;
