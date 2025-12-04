// Export all models
export * from "./User";
export * from "./Artist";
export * from "./Genre";
export * from "./Album";
export * from "./Song";
export * from "./Playlist";
export * from "./History";
export * from "./Favorite";

// Request Types
import { Request } from "express";

export interface AuthenticatedRequest extends Request {
  user?: {
    uid: string;
    email?: string;
    user_id?: number;
  };
}
