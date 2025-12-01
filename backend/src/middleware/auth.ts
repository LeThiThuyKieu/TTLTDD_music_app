import { Response, NextFunction } from "express";
import { firebaseAuth } from "../config/firebase";
import { AuthenticatedRequest } from "../types";

/**
 * Middleware để xác thực Firebase token
 */
export const authenticateFirebase = async (
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

    // Verify Firebase token
    const decodedToken = await firebaseAuth.verifyIdToken(token);

    // Attach user info to request
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
    };

    next();
  } catch (error: any) {
    console.error("Authentication error:", error);
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
      const decodedToken = await firebaseAuth.verifyIdToken(token);

      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
      };
    }

    next();
  } catch (error) {
    // Nếu token không hợp lệ, vẫn tiếp tục nhưng không có user
    next();
  }
};
