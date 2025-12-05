import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { AuthService } from "../services/authService";

export class AuthController {
  // Đăng ký/Đăng nhập - Tạo hoặc cập nhật user trong DB
  static async syncUser(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const { uid, email } = req.user;
      const { name, avatar_url } = req.body;

      const user = await AuthService.syncUser(uid, email, name, avatar_url);

      res.json({
        success: true,
        data: user,
      });
    } catch (error: any) {
      console.error("Sync user error:", error);
      res.status(500).json({
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
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const user = await AuthService.getCurrentUser(req.user.uid);

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
