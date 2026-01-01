import { Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { AuthenticatedRequest } from "../models";

const JWT_SECRET =
  process.env.JWT_SECRET || "your-secret-key-change-in-production";

/**
 * Middleware để xác thực JWT token
 */
export const authenticate = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).json({ error: "Unauthorized: No token provided" });
      return;
    }

    const token = authHeader.split("Bearer ")[1];

    // Verify JWT token
    const decoded = jwt.verify(token, JWT_SECRET) as {
      user_id: number;
      email: string;
    };

    // Attach user info to request
    req.user = {
      user_id: decoded.user_id,
      email: decoded.email,
    };

    next();
  } catch (error: any) {
    console.error("Authentication error:", error);
    if (error.name === "TokenExpiredError") {
      res.status(401).json({
        error: "Unauthorized: Token expired",
      });
      return;
    }
    if (error.name === "JsonWebTokenError") {
      res.status(401).json({
        error: "Unauthorized: Invalid token",
      });
      return;
    }
    res.status(401).json({
      error: "Unauthorized: Invalid token",
      message: error.message,
    });
  }
};

/**
 * Optional authentication - không bắt buộc phải có token
 */
export const optionalAuth = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith("Bearer ")) {
      const token = authHeader.split("Bearer ")[1];
      const decoded = jwt.verify(token, JWT_SECRET) as {
        user_id: number;
        email: string;
      };

      req.user = {
        user_id: decoded.user_id,
        email: decoded.email,
      };
    }

    next();
  } catch (error) {
    // Nếu token không hợp lệ, vẫn tiếp tục nhưng không có user
    next();
  }
};
