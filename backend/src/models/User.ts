// User Model
export interface User {
  user_id?: number;
  name: string;
  email: string;
  password_hash: string; // bcrypt hash
  avatar_url?: string;
  role?: "user" | "admin";
  is_active?: number;
  created_at?: Date;
  updated_at?: Date;
}
