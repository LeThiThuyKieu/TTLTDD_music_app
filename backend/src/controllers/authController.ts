import { Response, Request } from "express";
import { AuthenticatedRequest } from "../models";
import { AuthService } from "../services/authService";

export class AuthController {
  // Đăng ký user mới
  static async register(req: Request, res: Response): Promise<void> {
    try {
      const { name, email, password, avatar_url } = req.body;

      if (!name || !email || !password) {
        res.status(400).json({
          success: false,
          error: "Name, email, and password are required",
        });
        return;
      }

      const result = await AuthService.register(
        name,
        email,
        password,
        avatar_url
      );

      res.status(201).json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      console.error("Register error:", error);
      const statusCode = error.message === "Email already exists" ? 409 : 500;
      res.status(statusCode).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Đăng nhập
  static async login(req: Request, res: Response): Promise<void> {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        res.status(400).json({
          success: false,
          error: "Email and password are required",
        });
        return;
      }

      const result = await AuthService.login(email, password);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      console.error("Login error:", error);
      const statusCode =
        error.message === "Invalid email or password" ||
        error.message === "User account is inactive"
          ? 401
          : 500;
      res.status(statusCode).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Lấy thông tin user hiện tại
  static async getCurrentUser(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      if (!req.user || !req.user.user_id) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const user = await AuthService.getCurrentUser(req.user.user_id);

      if (!user) {
        res.status(404).json({ error: "User not found" });
        return;
      }

      res.json({
        success: true,
        data: user,
      });
    } catch (error: any) {
      console.error("Get current user error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}
