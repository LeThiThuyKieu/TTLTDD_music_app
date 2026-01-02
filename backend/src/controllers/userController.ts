import { Response } from "express";
import { AuthenticatedRequest } from "../models";
import { UserService } from "../services/userService";

export class UserController {
  // Lấy thông tin user theo ID
  static async getUserById(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      const userId = parseInt(req.params.id);
      if (isNaN(userId)) {
        res.status(400).json({ error: "Invalid user ID" });
        return;
      }

      const user = await UserService.getUserById(userId);
      if (!user) {
        res.status(404).json({ error: "User not found" });
        return;
      }

      res.json({
        success: true,
        data: user,
      });
    } catch (error: any) {
      console.error("Get user by ID error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Change password (trong profile)
  static async changePassword(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      if (!req.user || !req.user.user_id) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const { old_password, new_password } = req.body;

      if (!old_password || !new_password) {
        res.status(400).json({
          success: false,
          error: "Old password and new password are required",
        });
        return;
      }

      if (new_password.length < 6) {
        res.status(400).json({
          success: false,
          error: "Password must be at least 6 characters",
        });
        return;
      }

      await UserService.changePassword(
        req.user.user_id,
        old_password,
        new_password
      );

      res.json({
        success: true,
        message: "Đổi mật khẩu thành công",
      });
    } catch (error: any) {
      console.error("Change password error:", error);

      const statusCode =
        error.message === "Mật khẩu hiện tại không đúng" ? 400 : 500;

      res.status(statusCode).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }

  // Cập nhật name của user trong profile 
  static async updateNameProfile(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      const userId = req.user?.user_id;

      if (!userId) {
        res.status(401).json({ success: false, error: "Unauthorized" });
        return;
      }

      const { name } = req.body;

      if (!name || name.trim() === "") {
        res.status(400).json({
          success: false,
          error: "Name is required",
        });
        return;
      }

      const updatedUser = await UserService.updateNameProfile(userId, { name });

      if (!updatedUser) {
        res.status(404).json({
          success: false,
          error: "User not found",
        });
        return;
      }

      res.json({
        success: true,
        data: updatedUser,
      });
    } catch (error: any) {
      console.error("Update profile error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Internal server error",
      });
    }
  }
}
