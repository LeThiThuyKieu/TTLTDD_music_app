import { Response } from "express";
import { AuthenticatedRequest } from "../types";
import { UserModel } from "../models/User";
import { firebaseAuth } from "../config/firebase";

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

      // Lấy thông tin từ Firebase
      const firebaseUser = await firebaseAuth.getUser(uid);

      // Kiểm tra user đã tồn tại chưa
      let user = await UserModel.findByFirebaseUid(uid);

      if (user) {
        // Cập nhật thông tin nếu có thay đổi
        const updates: any = {};
        if (name) updates.name = name;
        if (avatar_url !== undefined) updates.avatar_url = avatar_url;
        if (firebaseUser.email && firebaseUser.email !== user.email) {
          updates.email = firebaseUser.email;
        }

        if (Object.keys(updates).length > 0) {
          user = await UserModel.update(user.user_id!, updates);
        }
      } else {
        // Tạo user mới
        user = await UserModel.create({
          firebase_uid: uid,
          name: name || firebaseUser.displayName || "User",
          email: email || firebaseUser.email || "",
          avatar_url: avatar_url || firebaseUser.photoURL || null,
        });
      }

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

      const user = await UserModel.findByFirebaseUid(req.user.uid);

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




