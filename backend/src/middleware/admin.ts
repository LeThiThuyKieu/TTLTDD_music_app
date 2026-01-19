import { Response, NextFunction } from "express";
import { AuthenticatedRequest } from "../models";

// Middleware: chỉ cho phép admin
export const requireAdmin = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): void => {
  // Chưa đăng nhập hoặc không có user
  if (!req.user) {
    res.status(401).json({
      success: false,
      error: "Unauthorized",
    });
    return;
  }

  // Không phải admin
  if (req.user.role !== "admin") {
    res.status(403).json({
      success: false,
      error: "Forbidden: Admin access required",
    });
    return;
  }

  // OK → cho đi tiếp
  next();
};
