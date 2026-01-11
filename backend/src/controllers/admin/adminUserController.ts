import { AuthenticatedRequest } from "../../models";
import { AdminUserService } from "../../services/admin/adminUserServices";
import { Response } from "express";

export class AdminUserController {
//ADMIN: lấy danh sách người dùng ( GET /api/admin/users )
    static async getAllUsers(req: AuthenticatedRequest, res: Response) {
       try {    
         const limit = Number(req.query.limit) || 20;
            const offset = Number(req.query.offset) || 0;
            const users = await AdminUserService.getAllUsers(limit, offset);
            res.status(200).json({
        success: true,
        limit,
        offset,
        data: users
        });
        } catch (error) {
        console.error("Admin get users error:", error);
        res.status(500).json({
        success: false,
        message: "Failed to fetch admin users"
        });
        }
}

    //ADMIN: Khoá tài khoản người dùng theo ID ( PATCH /api/admin/users/:id/status )
     static async toggleUserStatusById(
    req: AuthenticatedRequest,
    res: Response
  ) {
    try {
      const user_id = Number(req.params.id);
      const { is_active } = req.body;

      if (isNaN(user_id)) {
        return res.status(400).json({
          success: false,
          message: "Invalid user ID",
        });
      }

      if (![0, 1].includes(is_active)) {
        return res.status(400).json({
          success: false,
          message: "Invalid is_active value",
        });
      }

      // call service 
      await AdminUserService.toggleUserStatusById(user_id, is_active);

      return res.status(200).json({
        success: true,
        message: "User status updated successfully",
        user_id: user_id,
        is_active: is_active,
      });
    } catch (error: any) {
      console.error("Admin toggle user status error:", error);

      return res.status(400).json({
        success: false,
        message: error.message || "Failed to update user status",
      });
    }
  }
}