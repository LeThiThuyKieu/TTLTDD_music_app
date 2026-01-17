import { Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { AuthenticatedRequest } from "../models";

const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key-change-in-production";

type JwtPayloadAny = {
  user_id?: number | string;
  userId?: number | string;
  id?: number | string;
  sub?: number | string;
  email?: string;
  role?: "user" | "admin";
  [key: string]: any;
};

const extractUid = (decoded: JwtPayloadAny) =>
  decoded.user_id ?? decoded.userId ?? decoded.id ?? decoded.sub;

const attachUser = (req: AuthenticatedRequest, decoded: JwtPayloadAny) => {
  const uid = extractUid(decoded);

  if (!uid) return false;

  req.user = {
    user_id: Number(uid),
    email: decoded.email,
    role: decoded.role,
  };

  return true;
};

// ✅ Bắt buộc có token
export const authenticate = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): void => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith("Bearer ")) {
      res
        .status(401)
        .json({ success: false, error: "Unauthorized: No token provided" });
      return;
    }

    const token = authHeader.substring("Bearer ".length).trim();
    const decoded = jwt.verify(token, JWT_SECRET) as JwtPayloadAny;

    const ok = attachUser(req, decoded);
    if (!ok) {
      res.status(401).json({
        success: false,
        error: "Unauthorized: Invalid token payload",
      });
      return;
    }

    next();
  } catch (error: any) {
    res.status(401).json({
      success: false,
      error:
        error?.name === "TokenExpiredError"
          ? "Unauthorized: Token expired"
          : "Unauthorized: Invalid token",
      message: error?.message,
    });
  }
};

// ✅ Không bắt buộc token (dùng cho route public nhưng muốn biết user nếu có)
export const optionalAuth = (
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
): void => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader?.startsWith("Bearer ")) {
      const token = authHeader.substring("Bearer ".length).trim();
      const decoded = jwt.verify(token, JWT_SECRET) as JwtPayloadAny;
      attachUser(req, decoded); // fail thì thôi, vẫn next
    }

    next();
  } catch {
    next();
  }
};
