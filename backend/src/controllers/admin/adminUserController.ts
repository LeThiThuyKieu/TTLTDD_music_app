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
}