import { Response } from "express";
import { AuthenticatedRequest } from "../types";
import { UserService } from "../services/userService";

export class UserController {
  // Cập nhật profile
  static async updateProfile(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ error: "Unauthorized" });
        return;
      }

      const user = await UserService.getUserByFirebaseUid(req.user.uid);
      if (!user || !user.user_id) {
        res.status(404).json({ error: "User not found" });
        return;
      }

      const { name, avatar_url } = req.body;
      const updatedUser = await UserService.updateProfile(user.user_id, {
        name,
        avatar_url,
      });

      if (!updatedUser) {
        res.status(404).json({ error: "User not found" });
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
}
